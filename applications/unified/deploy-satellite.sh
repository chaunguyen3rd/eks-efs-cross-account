#!/bin/bash

# Deploy EFS Application to Satellite Cluster
# This script deploys the unified application to the satellite cluster

set -e

echo "Deploying EFS Application to Satellite Cluster..."

# Check if required environment variables are set
if [ -z "$EFS_ID" ]; then
    echo "Error: EFS_ID environment variable is required"
    echo "Please set it with: export EFS_ID=fs-xxxxxx"
    exit 1
fi

if [ -z "$SATELLITE_CROSS_ACCOUNT_ROLE_ARN" ]; then
    echo "Error: SATELLITE_CROSS_ACCOUNT_ROLE_ARN environment variable is required"
    echo "Please set it with: export SATELLITE_CROSS_ACCOUNT_ROLE_ARN=arn:aws:iam::xxxxx:role/xxxxx"
    exit 1
fi

# Set cluster-specific variables
export CLUSTER_TYPE="satellite"
export APP_NAME="satellite-app"
export EFS_ROLE_ARN="$SATELLITE_CROSS_ACCOUNT_ROLE_ARN"

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
