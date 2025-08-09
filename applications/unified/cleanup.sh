#!/bin/bash

# Cleanup EFS File Upload Application
# This script removes the unified file upload application from the current cluster

set -e

echo "🧹 Cleaning up EFS File Upload Application..."

# Delete all resources
echo "Deleting application resources..."
kubectl delete deployment efs-file-upload-app --ignore-not-found=true
kubectl delete service efs-app-service --ignore-not-found=true
kubectl delete ingress efs-app-ingress --ignore-not-found=true
kubectl delete configmap file-upload-app --ignore-not-found=true

echo "Deleting storage resources..."
kubectl delete pvc efs-claim --ignore-not-found=true
kubectl delete storageclass efs-sc --ignore-not-found=true

echo "Checking remaining resources..."
kubectl get pods -l app=efs-app || echo "No pods found"
kubectl get all -l app=efs-app || echo "No resources found"

echo "✅ Cleanup completed!"
echo "All EFS file upload application resources have been removed from the current cluster."
echo ""
echo "Note: The EFS file system and stored files are preserved."
echo "To view stored files later, redeploy the application or access EFS directly."
