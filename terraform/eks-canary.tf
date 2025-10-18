module "vpc" {
  source = "./vpc_module/"
}

locals {
  cluster_info = {
    blue = {
      cluster_name = "eks-canary"
      version  = "1.33"
    }
    # green = {
    #   project_name = "eks-canary-132"
    #   version  = "1.32"
    # }
    # purple = {
    #   project_name = "eks-canary-134"
    #   version  = "1.34"
    # }
  }
}

module "eks" {
  for_each = local.cluster_info

  source = "./eks_module/"

  aws_sg_eks_cluster_id = module.vpc.aws_sg_eks_cluster_id
  module_vpc_subnet_public_a_id = module.vpc.subnet_public_a_id
  module_vpc_subnet_public_b_id = module.vpc.subnet_public_b_id
  cluster_name = each.value.cluster_name
  cluster_version = each.value.version
}

# output "nested_info" {
#     value = module.eks["blue"].Lambda_Function_Names_nested
# }
