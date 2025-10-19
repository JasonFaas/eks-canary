
# EKS cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.aws_eks_cluster_role_arn

  vpc_config {
    subnet_ids              = [var.module_vpc_subnet_public_a_id, var.module_vpc_subnet_public_b_id]
    endpoint_public_access  = true
    endpoint_private_access = false
    security_group_ids      = [var.aws_sg_eks_cluster_id]
  }
}

# Node groups in different AZs with minimal instance types
resource "aws_eks_node_group" "ng_a" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ng-a"
  node_role_arn = var.aws_eks_node_role_arn
  subnet_ids      = [var.module_vpc_subnet_public_a_id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"
}

resource "aws_eks_node_group" "ng_b" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ng-b"
  node_role_arn = var.aws_eks_node_role_arn
  subnet_ids      = [var.module_vpc_subnet_public_b_id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"
}
