# Route53 Canary Deployment Configuration

This configuration sets up Route53 weighted routing for canary deployments with your EKS clusters.

## Features

- **Weighted Routing**: Distribute traffic between blue (production) and green (canary) clusters
- **Health Checks**: Automatic health monitoring for both clusters
- **Direct Access**: Separate domains for direct access to each cluster
- **Flexible Configuration**: Support for existing or new hosted zones

## Setup Instructions

### 1. Configure Your Domain

Edit `terraform.tfvars` or create it from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update the following variables:
- `domain_name`: Your actual domain (e.g., "myapp.com")
- `subdomain`: The subdomain for your app (e.g., "app" creates "app.myapp.com")
- `blue_weight` and `green_weight`: Traffic distribution weights

### 2. Load Balancer Naming

The configuration assumes your Kubernetes services create NLBs with this naming pattern:
- Blue cluster: `k8s-eks-canary-nginx`
- Green cluster: `k8s-eks-canary-132-nginx`

If your NLBs have different names, update the data sources in `route53.tf`:

```hcl
data "aws_lb" "blue_cluster" {
  count = 1
  name  = "your-actual-blue-nlb-name"
}

data "aws_lb" "green_cluster" {
  count = 1
  name  = "your-actual-green-nlb-name"
}
```

### 3. Deploy the Configuration

```bash
terraform init
terraform plan
terraform apply
```

### 4. Configure Your Domain Registrar

After deployment, you'll get name servers from the output. Update your domain registrar to use these name servers:

```bash
terraform output route53_name_servers
```

## Domain Structure

After deployment, you'll have these domains:

- **Main App**: `app.myapp.com` (weighted routing between blue and green)
- **Blue Direct**: `blue.app.myapp.com` (direct access to blue cluster)
- **Green Direct**: `green.app.myapp.com` (direct access to green cluster)

## Canary Deployment Workflow

### Initial Deployment (90/10 split)
```bash
# Update weights in terraform.tfvars
blue_weight = 90
green_weight = 10

terraform apply
```

### Increase Canary Traffic (50/50 split)
```bash
blue_weight = 50
green_weight = 50

terraform apply
```

### Full Canary Cutover (0/100 split)
```bash
blue_weight = 0
green_weight = 100

terraform apply
```

### Rollback (100/0 split)
```bash
blue_weight = 100
green_weight = 0

terraform apply
```

## Using Existing Hosted Zone

If you already have a Route53 hosted zone:

1. Set `use_existing_zone = true`
2. Provide your zone ID in `existing_zone_id`
3. The configuration will use your existing zone instead of creating a new one

## Health Checks

The configuration includes health checks for both clusters:
- **Path**: `/` (root path)
- **Port**: 80
- **Protocol**: HTTP
- **Interval**: 30 seconds
- **Failure Threshold**: 3 consecutive failures

Make sure your applications respond to health checks on the root path.

## Troubleshooting

### Load Balancer Not Found
If you get errors about load balancers not being found:
1. Check that your Kubernetes services are deployed and have external IPs
2. Verify the NLB naming pattern matches your actual load balancers
3. Use `aws elbv2 describe-load-balancers` to see actual NLB names

### DNS Not Propagating
- DNS changes can take up to 48 hours to propagate globally
- Use `dig` or `nslookup` to check DNS resolution
- Consider using a DNS propagation checker tool

### Health Check Failures
- Ensure your application responds to HTTP requests on port 80
- Check security groups allow traffic from Route53 health checkers
- Verify the health check path exists on your application

## Cost Considerations

- Route53 hosted zone: ~$0.50/month
- Health checks: ~$0.50/month per health check (2 health checks = ~$1/month)
- DNS queries: $0.40 per million queries
- Total estimated cost: ~$2-5/month depending on traffic

## Security

- Health checks are performed from AWS IP ranges
- Ensure your security groups allow traffic from Route53 health checkers
- Consider implementing authentication for your health check endpoints in production
