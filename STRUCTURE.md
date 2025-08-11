# Project Structure

```text
eks-terraform/
├── README.md                           # Project overview and architecture
├── SETUP.md                           # Detailed setup and troubleshooting guide
├── STRUCTURE.md                       # This file - project structure documentation
├── corebank/                          # Corebank account infrastructure
│   ├── main.tf                        # Main Terraform configuration
│   ├── variables.tf                   # Variable definitions
│   ├── outputs.tf                     # Output values
│   └── terraform.tfvars.example       # Example configuration file
├── satellite/                         # Satellite account infrastructure
│   ├── main.tf                        # Main Terraform configuration
│   ├── variables.tf                   # Variable definitions
│   ├── outputs.tf                     # Output values
│   └── terraform.tfvars.example       # Example configuration file
├── applications/                      # Kubernetes applications
│   └── unified/                       # Unified EFS S3 downloader application
│       ├── efs-app.yaml              # Kubernetes manifests (StorageClass, PVC, Deployment)
│       ├── deploy-corebank.sh        # Deployment script for corebank cluster
│       ├── deploy-satellite.sh       # Deployment script for satellite cluster
│       ├── cleanup.sh                # Application cleanup script
│       └── README.md                 # Application documentation
└── diagrams/                          # Architecture diagrams
    ├── cross-account-efs-simplified.png
    └── network-flow-simplified.png
```

## Key Features

### Infrastructure Components

1. **Corebank Account**:
   - EKS cluster with managed node groups
   - EFS file system with cross-account access policy
   - VPC with public/private subnets
   - VPC peering connection to satellite account
   - Security groups for EFS access
   - IAM roles for EFS CSI driver and cross-account access

2. **Satellite Account**:
   - EKS cluster with managed node groups
   - VPC with public/private subnets
   - VPC peering connection acceptance
   - Cross-account IAM role for EFS access
   - Security groups for EFS client access
   - Route table updates for cross-VPC communication

### Application Components

1. **Unified EFS S3 Downloader Application**:
   - Downloads files from public S3 bucket to EFS mount
   - Uses AWS CLI (`amazon/aws-cli:latest` image)
   - Demonstrates cross-account EFS access
   - Configurable S3 bucket and file list via environment variables
   - Persistent storage using Amazon EFS
   - Can be deployed to either corebank or satellite clusters

### Kubernetes Resources

The unified application creates:

- **StorageClass** (`efs-sc`): Configures EFS CSI driver with cross-account access
- **PersistentVolumeClaim** (`efs-claim`): Claims 5Gi of EFS storage
- **Deployment** (`efs-s3-downloader`): Long-running pod that downloads and persists files

### Network Architecture

- **VPC Peering**: Enables communication between corebank and satellite accounts
- **Security Groups**: Control NFS traffic (port 2049) for EFS access
- **Route Tables**: Updated for cross-VPC routing
- **EFS Mount Targets**: Available in all private subnets across both accounts

### Security Features

- **IRSA (IAM Roles for Service Accounts)**: Secure pod-level permissions
- **Cross-Account Policies**: Controlled access to EFS from satellite account
- **Encrypted EFS**: Data encryption at rest and in transit
- **VPC Security**: Private subnets for EKS nodes
- **Cross-Account Secrets**: Secure credential sharing for EFS CSI driver

## Quick Start

1. **Configure AWS Profiles**:

   ```bash
   aws configure --profile corebank
   aws configure --profile satellite
   ```

2. **Setup Configuration**:

   ```bash
   cp corebank/terraform.tfvars.example corebank/terraform.tfvars
   cp satellite/terraform.tfvars.example satellite/terraform.tfvars
   # Edit both terraform.tfvars files with your values
   ```

3. **Deploy Infrastructure**:

   ```bash
   # Deploy corebank first
   cd corebank
   terraform init && terraform apply
   
   # Note the outputs, then deploy satellite
   cd ../satellite
   terraform init && terraform apply
   ```

4. **Deploy Application**:

   ```bash
   cd applications/unified
   
   # Configure efs-app.yaml with your S3 bucket and files
   # Deploy to corebank cluster
   ./deploy-corebank.sh
   
   # Or deploy to satellite cluster
   ./deploy-satellite.sh
   ```

5. **Monitor Application**:

   ```bash
   # Check pods and logs
   kubectl get pods
   kubectl logs -l app=efs-s3-downloader -f
   
   # Verify downloaded files
   kubectl exec -it <pod-name> -- ls -la /data
   ```

6. **Cleanup**:

   ```bash
   cd applications/unified
   ./cleanup.sh
   
   # Then destroy infrastructure
   cd ../../satellite && terraform destroy
   cd ../corebank && terraform destroy
   ```

## Customization

### Network Configuration

- Modify CIDR blocks in `terraform.tfvars` files to avoid conflicts
- Adjust subnet configurations in `variables.tf`
- Update security group rules for additional ports if needed

### EKS Configuration

- Change instance types in `main.tf` for cost optimization
- Modify node group sizing based on workload requirements
- Add additional managed node groups for different workload types

### Application Configuration

- Update `S3_BUCKET_URL` environment variable in `efs-app.yaml`
- Modify `FILES_TO_DOWNLOAD` list for different files
- Adjust resource requests/limits based on file sizes
- Add health checks and readiness probes

### Security Configuration

- Adjust security group rules for additional services
- Modify IAM policies for least privilege access
- Configure additional RBAC rules for different teams

## Cross-Account Architecture Benefits

1. **Data Isolation**: Corebank data remains in controlled account
2. **Access Control**: Granular permissions for satellite account access
3. **Network Segmentation**: Separate VPCs with controlled peering
4. **Compliance**: Meets regulatory requirements for data separation
5. **Scalability**: Easy to add more satellite accounts or applications

## Cost Optimization

- Use Spot instances for non-production workloads
- Implement cluster autoscaling for dynamic node management
- Use EFS Infrequent Access storage class for rarely accessed files
- Configure appropriate EFS throughput mode (provisioned vs bursting)
- Use smaller instance types for lightweight applications

## Monitoring and Logging

Consider adding:

- CloudWatch Container Insights for EKS monitoring
- EFS performance monitoring and CloudWatch metrics
- VPC Flow Logs for network traffic analysis
- AWS X-Ray for application tracing
- Prometheus and Grafana for custom metrics
- CloudTrail for API call auditing
