#!/bin/bash

# Deploy EFS File Upload Application to Corebank Cluster
# This script deploys the unified file upload application to the corebank cluster

set -e

echo "Deploying EFS File Upload Application to Corebank Cluster..."

# Set cluster-specific variables
export CLUSTER_TYPE="corebank"
export APP_NAME="corebank-file-upload"
export EFS_ID="fs-041b4bd54a0879aca"
export EFS_ROLE_ARN="arn:aws:iam::590183822512:role/banking-platform-corebank-efs-csi-driver-role"

echo "Configuration:"
echo "  Cluster Type: $CLUSTER_TYPE"
echo "  App Name: $APP_NAME"
echo "  EFS ID: $EFS_ID"
echo "  Role ARN: $EFS_ROLE_ARN"

# Apply the configuration
envsubst < efs-app.yaml | kubectl apply -f -

echo "Checking deployment status..."
kubectl get pods -l app=efs-app
kubectl get svc efs-app-service
kubectl get pvc efs-claim

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/efs-file-upload-app

echo "Deployment completed for corebank cluster!"
echo ""
echo "📋 Next steps:"
echo "  • Check deployment: kubectl get pods -l app=efs-app"
echo "  • View logs: kubectl logs -l app=efs-app -f"
echo "  • Get service URL: kubectl get svc efs-app-service"
echo "  • Access the application through the LoadBalancer endpoint"
echo ""
echo "📁 Application Features:"
echo "  • Upload multiple files (images, documents, videos)"
echo "  • View uploaded files with metadata"
echo "  • Download files"
echo "  • Files stored on EFS for persistence and cross-AZ availability"
