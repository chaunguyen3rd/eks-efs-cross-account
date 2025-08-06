# Prerequisites and Setup Guide

## Prerequisites

### 1. AWS Accounts Setup
- Two AWS accounts: one for "corebank" and one for "satellite"
- Administrative access to both accounts
- Cross-account trust relationships configured

### 2. Required Tools
- Terraform >= 1.0
- AWS CLI >= 2.0
- kubectl >= 1.21
- bash shell

### 3. AWS CLI Profiles
Configure AWS CLI profiles for both accounts:

```bash
# Configure corebank account
aws configure --profile corebank
# Enter Access Key ID, Secret Key, and region (e.g., us-west-2)

# Configure satellite account
aws configure --profile satellite
# Enter Access Key ID, Secret Key, and region (e.g., us-west-2)
```

### 4. IAM Permissions
Both accounts need the following permissions:
- EKS full access
- VPC full access
- EFS full access
- IAM role creation and management
- EC2 full access

## Configuration Steps

### 1. Corebank Account Configuration
1. Copy `corebank/terraform.tfvars.example` to `corebank/terraform.tfvars`
2. Update the following values:
   ```hcl
   aws_region  = "us-west-2"  # Your preferred region
   aws_profile = "corebank"   # Your AWS profile name
   satellite_account_id = "123456789012"  # Satellite AWS account ID
   ```

### 2. Initial Deployment
First, deploy only the corebank infrastructure:

```bash
cd corebank
terraform init
terraform plan
terraform apply
```

Note the following outputs:
- `vpc_id`
- `vpc_peering_connection_id`
- `efs_id`

### 3. Satellite Account Configuration
1. Copy `satellite/terraform.tfvars.example` to `satellite/terraform.tfvars`
2. Update with values from corebank deployment:
   ```hcl
   aws_region  = "us-west-2"  # Same region as corebank
   aws_profile = "satellite"  # Your AWS profile name
   corebank_account_id = "987654321098"  # Corebank AWS account ID
   corebank_peering_connection_id = "pcx-xxxxx"  # From corebank output
   corebank_efs_id = "fs-xxxxx"  # From corebank output
   ```

### 4. Complete Deployment
Deploy satellite infrastructure:

```bash
cd satellite
terraform init
terraform plan
terraform apply
```

### 5. Application Deployment
Deploy the applications to both clusters:

```bash
# Deploy writer app to corebank
cd applications/writer
./deploy.sh

# Deploy reader app to satellite
cd ../reader
./deploy.sh
```

## Verification

### Check EKS Clusters
```bash
# Corebank cluster
aws eks list-clusters --profile corebank --region us-west-2

# Satellite cluster
aws eks list-clusters --profile satellite --region us-west-2
```

### Check Applications
```bash
# Connect to corebank cluster
aws eks update-kubeconfig --region us-west-2 --name banking-platform-corebank-eks --profile corebank
kubectl get pods -l app=efs-writer
kubectl logs -l app=efs-writer -f

# Connect to satellite cluster
aws eks update-kubeconfig --region us-west-2 --name banking-platform-satellite-eks --profile satellite
kubectl get pods -l app=efs-reader
kubectl logs -l app=efs-reader -f
```

### Verify Cross-Account EFS Access
The reader application in the satellite account should be able to read files written by the writer application in the corebank account.

## Troubleshooting

### Common Issues

1. **VPC Peering Connection Not Accepted**
   - Check if the peering connection is accepted in both accounts
   - Verify route tables are updated correctly

2. **EFS Mount Issues**
   - Verify security groups allow NFS traffic (port 2049)
   - Check if EFS mount targets are created in correct subnets

3. **IAM Permission Issues**
   - Verify IRSA (IAM Roles for Service Accounts) is configured correctly
   - Check cross-account policies for EFS access

4. **Pod Pending/Failed**
   - Check node capacity and resources
   - Verify storage class and PVC configuration

### Useful Commands

```bash
# Check EFS file system
aws efs describe-file-systems --profile corebank

# Check VPC peering status
aws ec2 describe-vpc-peering-connections --profile corebank

# Debug Kubernetes issues
kubectl describe pod <pod-name>
kubectl get events --sort-by=.metadata.creationTimestamp
```
