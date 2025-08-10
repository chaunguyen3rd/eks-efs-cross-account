#!/bin/bash

# Deploy EFS S3 Downloader Application to Satellite Cluster
# This script deploys the simplified S3 downloader application to the satellite cluster

set -e

echo "Deploying EFS S3 Downloader Application to Satellite Cluster..."

# Set cluster-specific variables
export CLUSTER_TYPE="satellite"
export APP_NAME="satellite-s3-downloader"
export EFS_ID="fs-041b4bd54a0879aca"

echo "Configuration:"
echo "  Cluster Type: $CLUSTER_TYPE"
echo "  App Name: $APP_NAME"
echo "  EFS ID: $EFS_ID"

# Apply the configuration
envsubst < efs-app.yaml | kubectl apply -f -

echo "Checking deployment status..."
kubectl get pods -l app=efs-app
kubectl get pvc efs-claim

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/efs-s3-downloader

echo "✅ Deployment completed!"
echo ""
echo "To check downloaded files:"
echo "  kubectl exec -it deployment/efs-s3-downloader -- ls -la /data/downloads/"
echo ""
echo "To access the container:"
echo "  kubectl exec -it deployment/efs-s3-downloader -- sh"
echo ""
echo "To check logs:"
echo "  kubectl logs -f deployment/efs-s3-downloader"
