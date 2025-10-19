# Route53 configuration for canary deployment with weighted routing

data "aws_lb" "clusters" {
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    # "kubernetes.io/service-name" = "default/nginx-service"
  }
}

# Health checks for the load balancers
resource "aws_route53_health_check" "all" {
  fqdn              = data.aws_lb.clusters.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  tags = {
    Name = "${var.hosted_zone_name}-${var.key_name}-health-check"
    Environment = "canary"
  }
}

# Weighted routing records for canary deployment
resource "aws_route53_record" "app_weighted" {
  zone_id = var.hosted_zone_id
  name    = "${var.subdomain}.${var.hosted_zone_name}"
  type    = "A"
  
  weighted_routing_policy {
    weight = var.routing_weight
  }
  
  set_identifier = "${var.cluster_name}-cluster"
  
  alias {
    name                   = data.aws_lb.clusters.dns_name
    zone_id                = data.aws_lb.clusters.zone_id
    evaluate_target_health = true
  }
  
  health_check_id = aws_route53_health_check.all.id
}

# Optional: Create a separate record for direct access to each cluster
resource "aws_route53_record" "app_direct" {
  zone_id = var.hosted_zone_id
  name    = "${var.key_name}.${var.subdomain}.${var.hosted_zone_name}"
  type    = "A"
  
  alias {
    name                   = data.aws_lb.clusters.dns_name
    zone_id                = data.aws_lb.clusters.zone_id
    evaluate_target_health = true
  }
}
