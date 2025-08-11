# Prerequisites and Setup Guide

## Prerequisites

### 1. AWS Accounts Setup

- Two AWS accounts: one for **corebank** and one for **satellite**
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
aws configure --profile corebank
aws configure --profile satellite
```

### 4. IAM Permissions

Both accounts need permissions for:

- EKS, VPC, EFS, EC2 full access
- IAM role creation and management

---

## Configuration Steps

### 1. Corebank Account Setup

1. Copy `corebank/terraform.tfvars.example` to `corebank/terraform.tfvars`
2. Update values for your environment:

   ```hcl
   aws_region  = "us-west-2"  # Your preferred region
   aws_profile = "corebank"   # Your AWS profile name
   environment  = "production"
   project_name = "banking-platform"
   satellite_account_id = "123456789012"  # Replace with actual satellite account ID
   satellite_vpc_cidr   = "10.1.0.0/16"
   ```

3. Deploy corebank infrastructure:

```bash
cd corebank
terraform init
terraform plan
terraform apply
```

**Note the following outputs:**

- `vpc_id`
- `vpc_peering_connection_id`
- `efs_id`

### 2. Satellite Account Setup

1. Copy `satellite/terraform.tfvars.example` to `satellite/terraform.tfvars`
2. Update with values from corebank deployment:

   ```hcl
   aws_region  = "us-west-2"  # Same region as corebank
   aws_profile = "satellite"  # Your AWS profile name
   environment  = "production"
   project_name = "banking-platform"
   corebank_account_id           = "987654321098"  # Replace with actual corebank account ID
   corebank_vpc_cidr            = "10.0.0.0/16"
   corebank_peering_connection_id = "pcx-xxxxxxxxx" # From corebank output
   corebank_efs_id              = "fs-xxxxxxxxx"   # From corebank output
   ```

3. Deploy satellite infrastructure:

```bash
cd satellite
terraform init
terraform plan
terraform apply
```

### 3. Application Deployment

#### Unified Application

The unified application is a simplified EFS S3 downloader that demonstrates downloading files from a public S3 bucket to an Amazon EFS mount using AWS CLI.

1. Navigate to the applications directory:

   ```bash
   cd applications/unified
   ```

2. Configure the application by editing `efs-app.yaml`:
   - Update `S3_BUCKET_URL` environment variable with your S3 bucket
   - Update `FILES_TO_DOWNLOAD` with space-separated list of files to download

3. Deploy the application to your EKS cluster:

   ```bash
   # Connect to your cluster first
   aws eks update-kubeconfig --region <region> --name <cluster-name> --profile <profile>
   
   # Deploy the application
   kubectl apply -f efs-app.yaml
   ```

#### Alternative Deployment Scripts

You can also use the provided deployment scripts:

```bash
# Deploy to corebank cluster
cd applications/unified
./deploy-corebank.sh

# Deploy to satellite cluster
./deploy-satellite.sh
```

## Verification

### Check EKS Clusters

```bash
# Corebank cluster
aws eks list-clusters --profile corebank --region <region>

# Satellite cluster
aws eks list-clusters --profile satellite --region <region>
```

### Check Application Pods

```bash
# Update kubeconfig for your cluster
aws eks update-kubeconfig --region <region> --name <cluster-name> --profile <profile>

# Check pods
kubectl get pods
kubectl get pvc
kubectl get storageclass

# Check logs
kubectl logs -l app=efs-s3-downloader
```

### Verify Cross-Account EFS Access

Files downloaded by the unified application in one account should be accessible via the EFS mount in the other account, demonstrating successful cross-account EFS sharing.

## Cleanup

To clean up resources, use the provided cleanup script:

```bash
cd applications/unified
./cleanup.sh
```

Then destroy Terraform infrastructure in reverse order:

```bash
# Destroy satellite infrastructure first
cd satellite
terraform destroy

# Then destroy corebank infrastructure
cd ../corebank
terraform destroy
```

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

# Check EFS CSI driver
kubectl get pods -n kube-system | grep efs-csi
```
