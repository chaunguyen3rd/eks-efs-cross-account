#!/bin/bash

# Master deployment script for the multi-account EKS setup

set -e

echo "=== Multi-Account EKS Deployment Script ==="
echo "This script will deploy infrastructure to both corebank and satellite accounts"
echo ""

# Check if required tools are installed
command -v terraform >/dev/null 2>&1 || { echo "terraform is required but not installed. Aborting." >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "aws CLI is required but not installed. Aborting." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed. Aborting." >&2; exit 1; }

# Function to check if AWS profile exists
check_aws_profile() {
    local profile=$1
    if ! aws configure list-profiles | grep -q "^$profile$"; then
        echo "AWS profile '$profile' not found. Please configure it first."
        echo "Run: aws configure --profile $profile"
        exit 1
    fi
    echo "✓ AWS profile '$profile' found"
}

# Check AWS profiles
echo "Checking AWS profiles..."
check_aws_profile "corebank"
check_aws_profile "satellite"

# Step 1: Deploy corebank infrastructure
echo ""
echo "=== Step 1: Deploying Corebank Infrastructure ==="
cd corebank

if [ ! -f "terraform.tfvars" ]; then
    echo "Please create terraform.tfvars in corebank/ directory based on terraform.tfvars.example"
    exit 1
fi

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform deployment..."
terraform plan

echo "Do you want to apply the corebank infrastructure? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    terraform apply
else
    echo "Deployment cancelled."
    exit 1
fi

# Get outputs from corebank deployment
VPC_ID=$(terraform output -raw vpc_id)
PEERING_CONNECTION_ID=$(terraform output -raw vpc_peering_connection_id)
EFS_ID=$(terraform output -raw efs_id)

echo "Corebank deployment completed!"
echo "VPC ID: $VPC_ID"
echo "Peering Connection ID: $PEERING_CONNECTION_ID"
echo "EFS ID: $EFS_ID"

cd ..

# Step 2: Update satellite terraform.tfvars with corebank outputs
echo ""
echo "=== Step 2: Preparing Satellite Configuration ==="

if [ ! -f "satellite/terraform.tfvars" ]; then
    echo "Creating satellite/terraform.tfvars from example..."
    cp satellite/terraform.tfvars.example satellite/terraform.tfvars
fi

echo "Please update satellite/terraform.tfvars with the following values:"
echo "corebank_peering_connection_id = \"$PEERING_CONNECTION_ID\""
echo "corebank_efs_id = \"$EFS_ID\""
echo ""
echo "Press Enter when you have updated the file..."
read -r

# Step 3: Deploy satellite infrastructure
echo ""
echo "=== Step 3: Deploying Satellite Infrastructure ==="
cd satellite

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform deployment..."
terraform plan

echo "Do you want to apply the satellite infrastructure? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    terraform apply
else
    echo "Deployment cancelled."
    exit 1
fi

echo "Satellite deployment completed!"
cd ..

# Step 4: Deploy applications
echo ""
echo "=== Step 4: Deploying Applications ==="

echo "Do you want to deploy the applications? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Deploying writer application to corebank..."
    cd applications/writer
    chmod +x deploy.sh
    ./deploy.sh
    
    echo "Deploying reader application to satellite..."
    cd ../reader
    chmod +x deploy.sh
    ./deploy.sh
    
    cd ../..
    
    echo ""
    echo "=== Deployment Complete! ==="
    echo ""
    echo "To monitor the applications:"
    echo ""
    echo "Corebank (writer):"
    echo "aws eks update-kubeconfig --region us-west-2 --name \$(cd corebank && terraform output -raw cluster_name) --profile corebank"
    echo "kubectl get pods -l app=efs-writer"
    echo "kubectl logs -l app=efs-writer -f"
    echo ""
    echo "Satellite (reader):"
    echo "aws eks update-kubeconfig --region us-west-2 --name \$(cd satellite && terraform output -raw cluster_name) --profile satellite"
    echo "kubectl get pods -l app=efs-reader"
    echo "kubectl logs -l app=efs-reader -f"
else
    echo "Applications not deployed. You can deploy them later using the deploy.sh scripts in applications/writer and applications/reader directories."
fi

echo ""
echo "Deployment completed successfully!"
