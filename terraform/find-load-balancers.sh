#!/bin/bash

# Script to find your actual load balancer names for Route53 configuration
# Run this script to see what NLBs are available and their names

echo "🔍 Finding your AWS Load Balancers..."
echo "=================================="

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    echo "   Visit: https://aws.amazon.com/cli/"
    exit 1
fi

echo "📋 All Network Load Balancers in your account:"
echo "----------------------------------------------"
aws elbv2 describe-load-balancers --query 'LoadBalancers[?Type==`network`].[LoadBalancerName,LoadBalancerArn,DNSName,State.Code]' --output table

echo ""
echo "📋 All Application Load Balancers in your account:"
echo "------------------------------------------------"
aws elbv2 describe-load-balancers --query 'LoadBalancers[?Type==`application`].[LoadBalancerName,LoadBalancerArn,DNSName,State.Code]' --output table

echo ""
echo "🎯 Load Balancers that might be from your EKS clusters:"
echo "------------------------------------------------------"
aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`) || contains(LoadBalancerName, `eks`) || contains(LoadBalancerName, `nginx`)].[LoadBalancerName,LoadBalancerArn,DNSName,Type]' --output table

echo ""
echo "💡 Next steps:"
echo "1. Look for NLBs (Type: network) that match your EKS cluster names"
echo "2. Update the data sources in route53.tf with the correct names"
echo "3. The naming pattern is usually: k8s-<cluster-name>-<service-name>-<hash>"
echo ""
echo "🔧 Example terraform.tfvars configuration:"
echo "------------------------------------------"
echo "# Use AWS test domain (free)"
echo "domain_name = \"example.com\""
echo "subdomain = \"myapp\""
echo "blue_weight = 90"
echo "green_weight = 10"
echo ""
echo "🌐 This will create: myapp.example.com"
echo "   - 90% traffic to blue cluster"
echo "   - 10% traffic to green cluster"
