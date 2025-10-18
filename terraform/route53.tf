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
resource "aws_route53_health_check" "all" {
  for_each = data.aws_lb.clusters
  fqdn              = each.value.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  tags = {
    Name = "${data.aws_route53_zone.existing.name}-${each.key}-health-check"
    Environment = "canary"
  }
}

# Weighted routing records for canary deployment
resource "aws_route53_record" "app_weighted" {
  for_each = local.cluster_info
  zone_id = local.route53_zone_id
  name    = "${local.subdomain}.${data.aws_route53_zone.existing.name}"
  type    = "A"
  
  weighted_routing_policy {
    weight = each.value.weight
  }
  
  set_identifier = "${each.value.cluster_name}-cluster"
  
  alias {
    name                   = data.aws_lb.clusters[each.key].dns_name
    zone_id                = data.aws_lb.clusters[each.key].zone_id
    evaluate_target_health = true
  }
  
  health_check_id = aws_route53_health_check.all[each.key].id
}

# Optional: Create a separate record for direct access to each cluster
resource "aws_route53_record" "app_direct" {
  for_each = local.cluster_info
  zone_id = local.route53_zone_id
  name    = "${each.key}.${local.subdomain}.${data.aws_route53_zone.existing.name}"
  type    = "A"
  
  alias {
    name                   = data.aws_lb.clusters[each.key].dns_name
    zone_id                = data.aws_lb.clusters[each.key].zone_id
    evaluate_target_health = true
  }
}
