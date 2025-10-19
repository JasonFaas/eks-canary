

# Note that weights can add up to 255
locals {
  cluster_info = {
    blue = {
      cluster_name = "eks-canary"
      version  = "1.33"
      weight = 10
    }
    green = {
      cluster_name = "eks-canary-132"
      version  = "1.32"
      weight = 90
    }
    purple = {
      cluster_name = "eks-canary-134"
      version  = "1.34"
      weight = 0
    }
  }

  existing_zone_id = "Z06622771EG9CWRHZ6QQ6" # jasonfaas.xyz
  use_existing_zone = true
  subdomain = "app"

  route53_zone_id = data.aws_route53_zone.existing.zone_id
}