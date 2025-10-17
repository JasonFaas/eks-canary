module "eks" {
  source = "./eks_module/"
}
module "vpc" {
  source = "./vpc_module/"
}

output "nested_info" {
    value = module.eks.Lambda_Function_Names_nested
}



# EKS IAM roles
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "eks-canary-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKS_VPC_ResourceController" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

data "aws_iam_policy_document" "nodes_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "nodes" {
  name               = "eks-canary-node-role"
  assume_role_policy = data.aws_iam_policy_document.nodes_assume_role.json
}

resource "aws_iam_role_policy_attachment" "nodes_worker" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "nodes_cni" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "nodes_ecr" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS cluster
resource "aws_eks_cluster" "this" {
  name     = "eks-canary"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = [module.vpc.subnet_public_a_id, module.vpc.subnet_public_b_id]
    endpoint_public_access  = true
    endpoint_private_access = false
    security_group_ids      = [module.vpc.aws_sg_eks_cluster_id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKS_VPC_ResourceController
  ]
}

# Node groups in different AZs with minimal instance types
resource "aws_eks_node_group" "ng_a" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ng-a"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [module.vpc.subnet_public_a_id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker,
    aws_iam_role_policy_attachment.nodes_cni,
    aws_iam_role_policy_attachment.nodes_ecr
  ]
}

resource "aws_eks_node_group" "ng_b" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ng-b"
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = [module.vpc.subnet_public_b_id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.nodes_worker,
    aws_iam_role_policy_attachment.nodes_cni,
    aws_iam_role_policy_attachment.nodes_ecr
  ]
}

output "node_group_names" {
  value = [aws_eks_node_group.ng_a.node_group_name, aws_eks_node_group.ng_b.node_group_name]
}

# Network Load Balancer for nginx service
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
    }
  }
  spec {
    selector = {
      app = "nginx-app"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "nginx_service_url" {
  value = "http://${kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.hostname}"
  description = "URL to access nginx service via NLB"
}

output "service_access_instructions" {
  value = <<-EOT
    Access the nginx service at: http://${kubernetes_service.nginx.status.0.load_balancer.0.ingress.0.hostname}
    
    The Network Load Balancer will automatically route traffic to your nginx pods.
    No need to worry about individual node IPs or NodePorts!
    
    Note: It may take a few minutes for the LoadBalancer to get an external IP.
    Check with: kubectl get svc nginx-service
  EOT
}


