#!/bin/bash

# Deploy EFS Application to Corebank Cluster
# This script deploys the unified application to the corebank cluster

set -e

echo "Deploying EFS Application to Corebank Cluster..."

# Set cluster-specific variables
export CLUSTER_TYPE="corebank"
export APP_NAME="corebank-app"
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

echo "Deployment completed for corebank cluster!"
echo "To check logs: kubectl logs -l app=efs-app -f"
