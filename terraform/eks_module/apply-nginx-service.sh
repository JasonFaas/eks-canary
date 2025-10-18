#!/bin/bash

# Script to apply the nginx service to the EKS cluster
# Make sure kubectl is configured to point to your EKS cluster

echo "Applying nginx service to EKS cluster..."

# Apply the nginx service
kubectl apply -f nginx-service.yaml

echo "Waiting for LoadBalancer to get external IP..."

# Wait for the service to get an external IP
kubectl wait --for=condition=Ready --timeout=300s service/nginx-service

echo "Getting LoadBalancer URL..."

# Get the LoadBalancer URL
LB_URL=$(kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -n "$LB_URL" ]; then
    echo "✅ Nginx service is available at: http://$LB_URL"
    echo "You can test it with: curl http://$LB_URL"
else
    echo "❌ LoadBalancer URL not available yet. Check with: kubectl get svc nginx-service"
fi
