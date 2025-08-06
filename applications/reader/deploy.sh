#!/bin/bash

# Script to deploy the EFS reader application in satellite account

set -e

echo "Deploying EFS Reader Application..."

# Get values from terraform outputs
CLUSTER_NAME=$(cd ../../satellite && terraform output -raw cluster_name)
COREBANK_EFS_ID=$(cd ../../satellite && terraform output -raw corebank_efs_id)
EFS_CROSS_ACCOUNT_ROLE_ARN=$(cd ../../satellite && terraform output -raw efs_cross_account_role_arn)
REGION=$(cd ../../satellite && terraform output -raw aws_region || echo "us-west-2")

echo "Cluster: $CLUSTER_NAME"
echo "Corebank EFS ID: $COREBANK_EFS_ID"
echo "Cross-account Role ARN: $EFS_CROSS_ACCOUNT_ROLE_ARN"
echo "Region: $REGION"

# Update kubeconfig for satellite account
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME --profile satellite

# Replace placeholders in the YAML file
sed "s/\${COREBANK_EFS_ID}/$COREBANK_EFS_ID/g; s|\${EFS_CROSS_ACCOUNT_ROLE_ARN}|$EFS_CROSS_ACCOUNT_ROLE_ARN|g" efs-reader.yaml > efs-reader-deploy.yaml

# Apply the configuration
kubectl apply -f efs-reader-deploy.yaml

echo "EFS Reader application deployed successfully!"
echo "Check the status with:"
echo "kubectl get pods -l app=efs-reader"
echo "kubectl logs -l app=efs-reader -f"
