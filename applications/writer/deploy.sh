#!/bin/bash

# Script to deploy the EFS writer application in corebank account

set -e

echo "Deploying EFS Writer Application..."

# Get EKS cluster name and region from terraform output
CLUSTER_NAME=$(cd ../../corebank && terraform output -raw cluster_name)
EFS_ID=$(cd ../../corebank && terraform output -raw efs_id)
REGION=$(cd ../../corebank && terraform output -raw aws_region || echo "us-west-2")

echo "Cluster: $CLUSTER_NAME"
echo "EFS ID: $EFS_ID"
echo "Region: $REGION"

# Update kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME --profile corebank

# Replace placeholders in the YAML file
sed "s/\${EFS_ID}/$EFS_ID/g" efs-writer.yaml > efs-writer-deploy.yaml

# Apply the configuration
kubectl apply -f efs-writer-deploy.yaml

echo "EFS Writer application deployed successfully!"
echo "Check the status with:"
echo "kubectl get pods -l app=efs-writer"
echo "kubectl logs -l app=efs-writer -f"
