# Unified EFS Application

This directory contains a simplified, unified application that can be deployed to both corebank and satellite EKS clusters. Both applications can read and write to the same EFS filesystem hosted in the corebank account.

## Features

- **Unified Application**: Single YAML configuration that works for both clusters
- **Read/Write Capability**: Both cluster deployments can read and write to the EFS
- **Cluster Identification**: Each deployment identifies itself with cluster type and unique app name
- **Shared Storage**: All data is stored in organized directories on the shared EFS
- **Simple Monitoring**: Applications log their activity and display current EFS state

## Directory Structure

```
unified/
├── efs-app.yaml              # Main application configuration
├── deploy-corebank.sh        # Deployment script for corebank cluster
├── deploy-satellite.sh       # Deployment script for satellite cluster
├── cleanup.sh               # Cleanup script for any cluster
└── README.md               # This file
```

## Prerequisites

1. **EFS Filesystem**: An EFS filesystem must exist in the corebank account
2. **EFS CSI Driver**: Must be installed on both EKS clusters
3. **IAM Roles**: Appropriate IAM roles for EFS access:
   - Corebank: Local role with EFS permissions
   - Satellite: Cross-account role with EFS permissions
4. **Environment Variables**: Required variables must be set before deployment

## Configuration

The application uses environment variables for configuration:

### For Corebank Deployment

```bash
export EFS_ID=fs-xxxxxxxxx                    # Your EFS filesystem ID
export COREBANK_ROLE_ARN=arn:aws:iam::ACCOUNT:role/ROLE_NAME
```

### For Satellite Deployment

```bash
export EFS_ID=fs-xxxxxxxxx                    # Same EFS filesystem ID
export SATELLITE_CROSS_ACCOUNT_ROLE_ARN=arn:aws:iam::ACCOUNT:role/CROSS_ACCOUNT_ROLE
```

## Deployment

### Deploy to Corebank Cluster

1. Set required environment variables:

```bash
export EFS_ID=fs-041b4bd54a0879aca
export COREBANK_ROLE_ARN=arn:aws:iam::123456789012:role/EFSAccessRole
```

2. Deploy the application:

```bash
cd applications/unified
./deploy-corebank.sh
```

### Deploy to Satellite Cluster

1. Set required environment variables:

```bash
export EFS_ID=fs-041b4bd54a0879aca
export SATELLITE_CROSS_ACCOUNT_ROLE_ARN=arn:aws:iam::123456789012:role/EFSCrossAccountRole
```

2. Deploy the application:

```bash
cd applications/unified
./deploy-satellite.sh
```

## Application Behavior

The unified application performs the following actions every 30 seconds:

1. **Writes Data**:
   - Logs activity to `/mnt/efs/logs/activity.log`
   - Creates data files in `/mnt/efs/data/` with cluster and timestamp information

2. **Reads Data**:
   - Lists current files in the EFS filesystem
   - Shows recent activity from the activity log
   - Displays data files from both clusters

3. **Displays Status**:
   - Shows cluster type, app name, and hostname
   - Reports file counts and recent files
   - Logs all activity with timestamps

## EFS Directory Structure

The application organizes data in the EFS filesystem as follows:

```
/mnt/efs/
├── logs/
│   └── activity.log          # Combined activity log from both clusters
└── data/
    ├── corebank-app-*.txt    # Data files from corebank cluster
    └── satellite-app-*.txt   # Data files from satellite cluster
```

## Monitoring

### Check Application Status

```bash
kubectl get pods -l app=efs-app
kubectl get pvc efs-pvc
kubectl get pv efs-pv
```

### View Application Logs

```bash
kubectl logs -l app=efs-app -f
```

### Check EFS Mount

```bash
kubectl exec -it deployment/efs-app -- sh
ls -la /mnt/efs/
cat /mnt/efs/logs/activity.log
```

## Cleanup

To remove the application from any cluster:

```bash
./cleanup.sh
```

This will remove all Kubernetes resources created by the application.

## Troubleshooting

### Common Issues

1. **Pod Pending**: Check if EFS CSI driver is installed and PV/PVC are bound
2. **Mount Failed**: Verify EFS ID, security groups, and IAM permissions
3. **Cross-Account Access**: Ensure the cross-account role has proper trust policies
4. **Permission Denied**: Check EFS access points and directory permissions

### Debug Commands

```bash
# Check EFS CSI driver
kubectl get pods -n kube-system | grep efs

# Check storage resources
kubectl describe pv efs-pv
kubectl describe pvc efs-pvc

# Check pod events
kubectl describe pod -l app=efs-app
```

## Key Improvements

This unified approach provides several benefits over the previous separate reader/writer apps:

1. **Simplified Architecture**: Single application template for both clusters
2. **Consistent Behavior**: Both deployments perform read and write operations
3. **Better Organization**: Structured data storage in EFS
4. **Easier Management**: Single set of deployment scripts
5. **Enhanced Monitoring**: Combined activity logging and status reporting
6. **Flexible Configuration**: Environment-based configuration for different clusters
