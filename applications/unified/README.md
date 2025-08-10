# Simplified EFS S3 Downloader Application

This is a simplified Kubernetes application that demonstrates downloading files from a public S3 bucket to an Amazon EFS (Elastic File System) mount. The application uses AWS CLI to directly download files to the EFS mount point.

## Architecture Overview

The application consists of:

1. **EFS Storage Class & PVC**: Configures Amazon EFS for persistent storage
2. **Deployment**: Long-running pod that downloads specified files from S3 to EFS

## Components

### 1. Storage Configuration

- **StorageClass (efs-sc)**: Configures EFS CSI driver with cross-account access
- **PersistentVolumeClaim (efs-claim)**: Claims 5Gi of EFS storage

### 2. Deployment (efs-s3-downloader)

- Uses `amazon/aws-cli:latest` image for S3 operations
- Downloads files from a configurable S3 bucket using AWS CLI
- Mounts EFS volume at `/data` to persist downloaded files
- Runs continuously to keep container and files available

## Configuration

### Environment Variables

Update these variables in the deployment:

- `S3_BUCKET_URL`: S3 bucket name (format: "s3://your-bucket-name")
- `FILES_TO_DOWNLOAD`: Space-separated list of files to download (e.g., "file1.txt file2.pdf image.jpg")

### Example Configuration

```yaml
env:
  - name: S3_BUCKET_URL
    value: "s3://my-public-bucket"
  - name: FILES_TO_DOWNLOAD
    value: "document.pdf data.csv image.jpg"
```

## Deployment Instructions

### Prerequisites

1. EKS cluster with EFS CSI driver installed
2. EFS file system created and accessible from EKS
3. Cross-account access configured (if applicable)
4. Update `${EFS_ID}` in the StorageClass

### Step 1: Update Configuration

1. Edit `efs-app.yaml` and replace `${EFS_ID}` with your actual EFS ID
2. Update the `S3_BUCKET_URL` environment variable with your bucket name
3. Update the `FILES_TO_DOWNLOAD` environment variable with the files you need

### Step 2: Deploy the Application

```bash
# Deploy the application
kubectl apply -f efs-app.yaml
```

### Step 3: Verify Deployment

```bash
# Check pod status
kubectl get pods -l app=efs-app

# Check download progress
kubectl logs -f deployment/efs-s3-downloader

# Check files in EFS mount
kubectl exec -it deployment/efs-s3-downloader -- ls -la /data/downloads/
```

## Usage

### Downloading Files

1. Update the `FILES_TO_DOWNLOAD` environment variable in the deployment
2. Apply the changes: `kubectl apply -f efs-app.yaml`
3. The pod will restart and download the specified files

### Accessing Downloaded Files

```bash
# List files in EFS mount
kubectl exec -it deployment/efs-s3-downloader -- ls -la /data/downloads/

# Interactive access
kubectl exec -it deployment/efs-s3-downloader -- sh
```

## Troubleshooting

### Common Issues

1. **Pod stuck in pending**: Check EFS CSI driver and storage class configuration
2. **Download failures**: Verify S3 bucket accessibility and file names
3. **Permission denied**: Check EFS mount options and directory permissions

### Debug Commands

```bash
# Check pod logs
kubectl logs -f deployment/efs-s3-downloader

# Access pod for debugging
kubectl exec -it deployment/efs-s3-downloader -- sh

# Check EFS mount
kubectl exec -it deployment/efs-s3-downloader -- df -h

# Test S3 access manually
kubectl exec -it deployment/efs-s3-downloader -- aws s3 ls s3://your-bucket-name/
```

## Security Considerations

1. **S3 Access**: Ensure proper S3 bucket permissions (public read or appropriate IAM roles)
2. **EFS Permissions**: Configure appropriate directory permissions (0755 by default)
3. **Resource Limits**: Set appropriate CPU/memory limits
4. **Network Policies**: Consider restricting network access if needed

## Resource Usage

The simplified application uses minimal resources:

- **CPU**: 100-200m
- **Memory**: 64-128Mi
- **Storage**: As needed for downloaded files

## Benefits of This Approach

1. **Simplicity**: Simple deployment with direct S3 downloads
2. **Lightweight**: Uses official AWS CLI image
3. **Flexible**: Easy to modify files to download via environment variables
4. **Persistent**: Files persist in EFS across pod restarts
5. **Reliable**: Uses native AWS CLI for S3 operations
6. **Cross-AZ**: EFS provides cross-availability zone access

## File Access from Other Pods

Other applications can access the downloaded files by mounting the same EFS PVC:

```yaml
volumeMounts:
  - name: shared-storage
    mountPath: /shared-data
volumes:
  - name: shared-storage
    persistentVolumeClaim:
      claimName: efs-claim
```

volumeMounts:
volumeMounts:

- name: shared-storage
    mountPath: /shared-data
volumes:
- name: shared-storage
    persistentVolumeClaim:
      claimName: efs-claim

```
- **After**: Simple script-based S3 file downloads
- **Benefit**: Reduced complexity, better automation, and integration capabilities
