#!/bin/bash

# Deploy EFS S3 Downloader Application to Satellite Cluster
# This script deploys the S3 downloader application that uses cross-account EFS access

set -e

echo "Deploying EFS S3 Downloader Application to Satellite Cluster..."

# Set cluster-specific variables
export CLUSTER_TYPE="satellite"
export APP_NAME="efs-s3-downloader"
export EFS_ID="fs-0f9767477ea91786e"

echo "Configuration:"
echo "  Cluster Type: $CLUSTER_TYPE"
echo "  App Name: $APP_NAME"
echo "  EFS ID: $EFS_ID (from corebank account)"

# Verify EFS ID is set
if [[ -z "$EFS_ID" ]]; then
    echo "❌ Error: EFS_ID is not set. Please provide the EFS file system ID from corebank account."
    exit 1
fi

# Apply the configuration
echo "Applying Kubernetes manifests..."
envsubst < efs-app.yaml | kubectl apply -f -

echo "Checking deployment status..."
kubectl get storageclass efs-sc
kubectl get pvc efs-claim
kubectl get deployment efs-s3-downloader

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/efs-s3-downloader

echo "✅ Deployment completed!"
echo ""
echo "📊 Checking application status:"
kubectl get pods -l app=efs-app

echo ""
echo "🔍 Useful commands:"
echo "  View application logs (with S3 download status):"
echo "    kubectl logs -f deployment/efs-s3-downloader"
echo ""
echo "  Check downloaded files in EFS:"
echo "    kubectl exec -it deployment/efs-s3-downloader -- ls -la /data/"
echo ""
echo "  Check EFS mount and disk usage:"
echo "    kubectl exec -it deployment/efs-s3-downloader -- df -h /data"
echo ""
echo "  Access the container shell:"
echo "    kubectl exec -it deployment/efs-s3-downloader -- sh"
echo ""
echo "  Monitor S3 download progress:"
echo "    kubectl exec -it deployment/efs-s3-downloader -- du -hs /data/*"
echo ""
echo "  Verify cross-account EFS access:"
echo "    kubectl get secret x-account -n kube-system"
echo ""
echo "📁 Application Features:"
echo "  • Downloads files from S3 to cross-account EFS storage"
echo "  • Uses cross-account EFS access via x-account secret"
echo "  • Files stored on corebank EFS for persistence and cross-AZ availability"
echo "  • Environment variables:"
echo "    - S3_BUCKET_URL: s3://core-efs-eks-cross-account-public-bucket"
echo "    - FILES_TO_DOWNLOAD: 21m.011-fall-2024"
