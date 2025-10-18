output "cluster_name" {
  value = module.eks["blue"].cluster_name
}

# output "nginx_service_url" {
#   value = module.eks["blue"].nginx_service_url
#   description = "URL to access nginx service via NLB"
# }

output "node_group_names" {
  value = module.eks["blue"].node_group_names
}
