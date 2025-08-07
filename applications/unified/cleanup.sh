#!/bin/bash

# Cleanup EFS Application
# This script removes the unified application from the current cluster

set -e

echo "Cleaning up EFS Application..."

# Delete all resources
kubectl delete deployment efs-app --ignore-not-found=true
kubectl delete service efs-app-service --ignore-not-found=true
kubectl delete pvc efs-pvc --ignore-not-found=true
kubectl delete pv efs-pv --ignore-not-found=true
kubectl delete storageclass efs-sc --ignore-not-found=true
kubectl delete serviceaccount efs-app-sa --ignore-not-found=true
kubectl delete configmap efs-app-config --ignore-not-found=true

echo "Cleanup completed!"
echo "All EFS application resources have been removed from the current cluster."
