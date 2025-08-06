# Multi-Account EKS with EFS Cross-Account Access

This Terraform configuration deploys:
- **Corebank Account**: EKS cluster with EFS and application to write files
- **Satellite Account**: EKS cluster with application to access EFS in corebank account

## Architecture

```
┌─────────────────────────────────────┐    ┌─────────────────────────────────────┐
│           Corebank Account          │    │          Satellite Account          │
│                                     │    │                                     │
│  ┌─────────────────────────────────┐ │    │  ┌─────────────────────────────────┐ │
│  │           EKS Cluster           │ │    │  │           EKS Cluster           │ │
│  │                                 │ │    │  │                                 │ │
│  │  ┌─────────────────────────────┐│ │    │  │  ┌─────────────────────────────┐│ │
│  │  │   Writer Application        ││ │    │  │  │   Reader Application        ││ │
│  │  │   (writes to EFS)           ││ │    │  │  │   (reads from EFS)          ││ │
│  │  └─────────────────────────────┘│ │    │  │  └─────────────────────────────┘│ │
│  └─────────────────────────────────┘ │    │  └─────────────────────────────────┘ │
│                                     │    │                                     │
│  ┌─────────────────────────────────┐ │    │                                     │
│  │              EFS                │ │◄───┼─────────────────────────────────────┤
│  │                                 │ │    │         Cross-Account               │
│  └─────────────────────────────────┘ │    │         Access                      │
└─────────────────────────────────────┘    └─────────────────────────────────────┘
```

## Prerequisites

1. Two AWS accounts (corebank and satellite)
2. AWS CLI configured with profiles for both accounts
3. Terraform installed
4. kubectl installed
5. Proper IAM permissions in both accounts

## Deployment Steps

1. **Deploy Corebank Infrastructure**:
   ```bash
   cd corebank
   terraform init
   terraform plan
   terraform apply
   ```

2. **Deploy Satellite Infrastructure**:
   ```bash
   cd ../satellite
   terraform init
   terraform plan
   terraform apply
   ```

3. **Deploy Applications**:
   ```bash
   # Deploy writer app in corebank
   cd ../applications/writer
   kubectl apply -f .

   # Deploy reader app in satellite
   cd ../reader
   kubectl apply -f .
   ```

## Configuration

Update the variables in each module's `terraform.tfvars` file according to your requirements.

## Cleanup

```bash
# Clean up satellite first
cd satellite
terraform destroy

# Then clean up corebank
cd ../corebank
terraform destroy
```
