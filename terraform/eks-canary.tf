module "vpc" {
  source = "./vpc_module/"
}

module "eks" {
  for_each = local.cluster_info

  source = "./eks_module/"

  aws_sg_eks_cluster_id = module.vpc.aws_sg_eks_cluster_id
  module_vpc_subnet_public_a_id = module.vpc.subnet_public_a_id
  module_vpc_subnet_public_b_id = module.vpc.subnet_public_b_id

  cluster_name = each.value.cluster_name
  cluster_version = each.value.version

  aws_eks_cluster_role_arn = module.vpc.aws_eks_cluster_role_arn
  aws_eks_node_role_arn = module.vpc.aws_eks_node_role_arn
}

# output "nested_info" {
#     value = module.eks["blue"].Lambda_Function_Names_nested
# }
