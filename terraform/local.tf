

locals {
  cluster_info = {
    blue = {
      cluster_name = "eks-canary"
      version  = "1.33"
      weight = 90
    }
    green = {
      cluster_name = "eks-canary-132"
      version  = "1.32"
      weight = 10
    }
    # purple = {
    #   cluster_name = "eks-canary-134"
    #   version  = "1.34"
    # }
  }

  existing_zone_id = "Z00155181XF0U1AI4G6G6" # learnlangagain.com
  use_existing_zone = true
  subdomain = "app"

  route53_zone_id = data.aws_route53_zone.existing.zone_id
}