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



# Outputs for Route53 information
output "route53_zone_id" {
  description = "The Route53 hosted zone ID"
  value       = local.route53_zone_id
}

output "route53_name_servers" {
  description = "The Route53 name servers for the hosted zone"
  value       = data.aws_route53_zone.existing.name_servers
}

output "app_domain_name" {
  description = "The main application domain name"
  value       = "${local.subdomain}.${data.aws_route53_zone.existing.name}"
}

output "blue_cluster_domain" {
  description = "Direct access domain for blue cluster"
  value       = "blue.${local.subdomain}.${data.aws_route53_zone.existing.name}"
}

output "green_cluster_domain" {
  description = "Direct access domain for green cluster"
  value       = "green.${local.subdomain}.${data.aws_route53_zone.existing.name}"
}



# TODO: Re-add
# output "health_check_blue_id" {
#   description = "Health check ID for blue cluster"
#   value       = aws_route53_health_check.blue_health[0].id
# }

# output "health_check_green_id" {
#   description = "Health check ID for green cluster"
#   value       = aws_route53_health_check.green_health[0].id
# }
