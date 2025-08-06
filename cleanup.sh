#!/bin/bash

# Cleanup script for the multi-account EKS setup

set -e

echo "=== Multi-Account EKS Cleanup Script ==="
echo "This script will destroy infrastructure in both accounts"
echo ""

# Function to check if directory exists and has terraform state
check_terraform_state() {
    local dir=$1
    if [ -d "$dir" ] && [ -f "$dir/terraform.tfstate" ]; then
        return 0
    else
        return 1
    fi
}

# Step 1: Cleanup applications first
echo "=== Step 1: Cleaning up Applications ==="

echo "Do you want to remove the applications? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Removing writer application from corebank..."
    if check_terraform_state "corebank"; then
        CLUSTER_NAME=$(cd corebank && terraform output -raw cluster_name 2>/dev/null || echo "")
        if [ -n "$CLUSTER_NAME" ]; then
            aws eks update-kubeconfig --region us-west-2 --name "$CLUSTER_NAME" --profile corebank 2>/dev/null || true
            kubectl delete -f applications/writer/efs-writer-deploy.yaml 2>/dev/null || true
        fi
    fi
    
    echo "Removing reader application from satellite..."
    if check_terraform_state "satellite"; then
        CLUSTER_NAME=$(cd satellite && terraform output -raw cluster_name 2>/dev/null || echo "")
        if [ -n "$CLUSTER_NAME" ]; then
            aws eks update-kubeconfig --region us-west-2 --name "$CLUSTER_NAME" --profile satellite 2>/dev/null || true
            kubectl delete -f applications/reader/efs-reader-deploy.yaml 2>/dev/null || true
        fi
    fi
fi

# Step 2: Destroy satellite infrastructure
echo ""
echo "=== Step 2: Destroying Satellite Infrastructure ==="

if check_terraform_state "satellite"; then
    cd satellite
    
    echo "Do you want to destroy the satellite infrastructure? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        terraform destroy
    else
        echo "Satellite infrastructure not destroyed."
    fi
    
    cd ..
else
    echo "No satellite terraform state found, skipping..."
fi

# Step 3: Destroy corebank infrastructure
echo ""
echo "=== Step 3: Destroying Corebank Infrastructure ==="

if check_terraform_state "corebank"; then
    cd corebank
    
    echo "Do you want to destroy the corebank infrastructure? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        terraform destroy
    else
        echo "Corebank infrastructure not destroyed."
    fi
    
    cd ..
else
    echo "No corebank terraform state found, skipping..."
fi

echo ""
echo "Cleanup completed!"
echo ""
echo "Note: If you encounter issues with VPC peering connections, you may need to:"
echo "1. Manually delete the peering connection in the AWS console"
echo "2. Re-run the destroy commands"
