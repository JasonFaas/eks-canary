# Route53 configuration for canary deployment with weighted routing

# Route53 Hosted Zone configuration
data "aws_route53_zone" "existing" {
  zone_id      = local.existing_zone_id
}

data "aws_lb" "clusters" {
  for_each = local.cluster_info
  tags = {
    "kubernetes.io/cluster/${each.value.cluster_name}" = "owned"
    # "kubernetes.io/service-name" = "default/nginx-service"
  }
}

# Health checks for the load balancers
resource "aws_route53_health_check" "blue_health" {
  for_each = data.aws_lb.clusters
  fqdn              = each.value.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  tags = {
    Name = "${data.aws_route53_zone.existing.name}-${each.value.cluster_name}-health-check"
    Environment = "canary"
  }
}

# Weighted routing records for canary deployment
resource "aws_route53_record" "app_weighted" {
  zone_id = local.route53_zone_id
  name    = "${local.subdomain}.${data.aws_route53_zone.existing.name}"
  type    = "A"
  
  # Weighted routing for blue cluster (primary)
  weighted_routing_policy {
    weight = local.blue_weight  # Configurable traffic weight for blue (current production)
  }
  
  set_identifier = "blue-cluster"
  
  alias {
    name                   = data.aws_lb.blue_cluster[0].dns_name
    zone_id                = data.aws_lb.blue_cluster[0].zone_id
    evaluate_target_health = true
  }
  
  health_check_id = aws_route53_health_check.blue_health[0].id
}

resource "aws_route53_record" "app_weighted_green" {
  zone_id = local.route53_zone_id
  name    = "${local.subdomain}.${data.aws_route53_zone.existing.name}"
  type    = "A"
  
  # Weighted routing for green cluster (canary)
  weighted_routing_policy {
    weight = local.green_weight  # Configurable traffic weight for green (canary deployment)
  }
  
  set_identifier = "green-cluster"
  
  alias {
    name                   = data.aws_lb.green_cluster[0].dns_name
    zone_id                = data.aws_lb.green_cluster[0].zone_id
    evaluate_target_health = true
  }
  
  health_check_id = aws_route53_health_check.green_health[0].id
}

# Optional: Create a separate record for direct access to each cluster
resource "aws_route53_record" "app_blue_direct" {
  zone_id = local.route53_zone_id
  name    = "blue.${local.subdomain}.${data.aws_route53_zone.existing.name}"
  type    = "A"
  
  alias {
    name                   = data.aws_lb.blue_cluster[0].dns_name
    zone_id                = data.aws_lb.blue_cluster[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app_green_direct" {
  zone_id = local.route53_zone_id
  name    = "green.${local.subdomain}.${data.aws_route53_zone.existing.name}"
  type    = "A"
  
  alias {
    name                   = data.aws_lb.green_cluster[0].dns_name
    zone_id                = data.aws_lb.green_cluster[0].zone_id
    evaluate_target_health = true
  }
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
