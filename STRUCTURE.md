# Project Structure

```
eks-terraform/
├── README.md                           # Project overview and architecture
├── SETUP.md                           # Detailed setup and troubleshooting guide
├── deploy.sh                          # Master deployment script
├── cleanup.sh                         # Master cleanup script
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
└── applications/                      # Kubernetes applications
    ├── writer/                        # EFS writer application (corebank)
    │   ├── efs-writer.yaml            # Kubernetes manifests
    │   └── deploy.sh                  # Deployment script
    └── reader/                        # EFS reader application (satellite)
        ├── efs-reader.yaml            # Kubernetes manifests
        └── deploy.sh                  # Deployment script
```

## Key Features

### Infrastructure Components

1. **Corebank Account**:
   - EKS cluster with managed node groups
   - EFS file system with cross-account access policy
   - VPC with public/private subnets
   - VPC peering connection to satellite account
   - Security groups for EFS access
   - IAM roles for EFS CSI driver

2. **Satellite Account**:
   - EKS cluster with managed node groups
   - VPC with public/private subnets
   - VPC peering connection acceptance
   - Cross-account IAM role for EFS access
   - Security groups for EFS client access

### Application Components

1. **Writer Application (Corebank)**:
   - Writes log files and test data to EFS
   - Uses EFS CSI driver for dynamic provisioning
   - Runs continuously with 30-second intervals

2. **Reader Application (Satellite)**:
   - Reads files from corebank EFS via cross-account access
   - Monitors and displays EFS contents
   - Demonstrates cross-VPC file system access

### Network Architecture

- **VPC Peering**: Enables communication between accounts
- **Security Groups**: Control NFS traffic (port 2049)
- **Route Tables**: Updated for cross-VPC routing
- **EFS Mount Targets**: Available in all private subnets

### Security Features

- **IRSA (IAM Roles for Service Accounts)**: Secure pod-level permissions
- **Cross-Account Policies**: Controlled access to EFS from satellite account
- **Encrypted EFS**: Data encryption at rest and in transit
- **VPC Security**: Private subnets for EKS nodes

## Quick Start

1. **Configure AWS Profiles**:
   ```bash
   aws configure --profile corebank
   aws configure --profile satellite
   ```

2. **Setup Configuration**:
   ```bash
   cp corebank/terraform.tfvars.example corebank/terraform.tfvars
   # Edit corebank/terraform.tfvars with your values
   ```

3. **Deploy Everything**:
   ```bash
   ./deploy.sh
   ```

4. **Monitor Applications**:
   ```bash
   # Writer logs (corebank)
   aws eks update-kubeconfig --region us-west-2 --name banking-platform-corebank-eks --profile corebank
   kubectl logs -l app=efs-writer -f

   # Reader logs (satellite)
   aws eks update-kubeconfig --region us-west-2 --name banking-platform-satellite-eks --profile satellite
   kubectl logs -l app=efs-reader -f
   ```

5. **Cleanup**:
   ```bash
   ./cleanup.sh
   ```

## Customization

### Network Configuration
- Modify CIDR blocks in `terraform.tfvars` files
- Adjust subnet configurations in `variables.tf`

### EKS Configuration
- Change instance types in `main.tf`
- Modify node group sizing
- Add additional managed node groups

### Application Configuration
- Customize container images
- Modify resource requests/limits
- Add health checks and monitoring

### Security Configuration
- Adjust security group rules
- Modify IAM policies
- Configure additional RBAC rules

## Cost Optimization

- Use Spot instances for non-production workloads
- Implement cluster autoscaling
- Use EFS Infrequent Access storage class
- Configure appropriate EFS throughput mode

## Monitoring and Logging

Consider adding:
- CloudWatch Container Insights
- EFS performance monitoring
- VPC Flow Logs
- AWS X-Ray for application tracing
- Prometheus and Grafana for metrics
