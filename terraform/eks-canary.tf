module "vpc" {
  source = "./module_vpc/"
}

module "eks" {
  for_each = local.cluster_info

  source = "./module_eks/"

  aws_sg_eks_cluster_id = module.vpc.aws_sg_eks_cluster_id
  module_vpc_subnet_public_a_id = module.vpc.subnet_public_a_id
  module_vpc_subnet_public_b_id = module.vpc.subnet_public_b_id

  cluster_name = each.value.cluster_name
  cluster_version = each.value.version

  aws_eks_cluster_role_arn = module.vpc.aws_eks_cluster_role_arn
  aws_eks_node_role_arn = module.vpc.aws_eks_node_role_arn
}

module "route53" {
  for_each = local.cluster_info
  
  source = "./module_route53/"

  hosted_zone_id = local.existing_zone_id
  hosted_zone_name = data.aws_route53_zone.existing.name
  cluster_name = each.value.cluster_name
  key_name = each.key
  subdomain = local.subdomain
  routing_weight = each.value.weight
}
