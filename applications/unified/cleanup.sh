#!/bin/bash

# Cleanup EFS S3 Downloader Application
# This script removes the simplified S3 downloader application from the current cluster

set -e

echo "🧹 Cleaning up EFS S3 Downloader Application..."

# Delete application resources
echo "Deleting application resources..."
kubectl delete deployment efs-s3-downloader --ignore-not-found=true

# Clean up any old resources from previous versions
kubectl delete job efs-s3-download-job --ignore-not-found=true
kubectl delete pod efs-file-viewer --ignore-not-found=true
kubectl delete service efs-app-service --ignore-not-found=true
kubectl delete configmap s3-download-script --ignore-not-found=true
kubectl delete deployment efs-file-upload-app --ignore-not-found=true
kubectl delete ingress efs-app-ingress --ignore-not-found=true
kubectl delete configmap file-upload-app --ignore-not-found=true

echo "Deleting storage resources..."
kubectl delete pvc efs-claim --ignore-not-found=true
kubectl delete storageclass efs-sc --ignore-not-found=true

echo "✅ Cleanup completed!"
echo ""
echo "Checking remaining resources..."
kubectl get pods -l app=efs-app 2>/dev/null || echo "No pods found with label app=efs-app"
kubectl get all -l app=efs-app 2>/dev/null || echo "No resources found with label app=efs-app"

echo ""
echo "Note: The EFS file system and stored files are preserved."
echo "To view stored files later, redeploy the application or access EFS directly."
