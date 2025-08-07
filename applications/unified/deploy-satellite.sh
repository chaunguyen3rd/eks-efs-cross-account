#!/bin/bash

# Deploy EFS Application to Satellite Cluster
# This script deploys the unified application to the satellite cluster

set -e

echo "Deploying EFS Application to Satellite Cluster..."

# Set cluster-specific variables
export CLUSTER_TYPE="satellite"
export APP_NAME="satellite-app"
export EFS_ID="fs-041b4bd54a0879aca"
export EFS_ROLE_ARN="arn:aws:iam::471112932773:role/banking-satellite-efs-cross-account-role"

echo "Configuration:"
echo "  Cluster Type: $CLUSTER_TYPE"
echo "  App Name: $APP_NAME"
echo "  EFS ID: $EFS_ID"
echo "  Role ARN: $EFS_ROLE_ARN"

# Apply the configuration
envsubst < efs-app.yaml | kubectl apply -f -

echo "Checking deployment status..."
kubectl get pods -l app=efs-app
kubectl get pvc efs-pvc
kubectl get pv efs-pv

echo "Deployment completed for satellite cluster!"
echo "To check logs: kubectl logs -l app=efs-app -f"
