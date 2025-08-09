# EFS File Upload Application

A simple web application that allows users to upload images and files to Amazon EFS (Elastic File System) storage. The application is designed to run on Amazon EKS clusters with cross-account EFS access.

## Features

- 📤 **Multi-file Upload**: Upload multiple files simultaneously
- 🖼️ **Image Support**: PNG, JPG, JPEG, GIF formats
- 📄 **Document Support**: PDF, DOC, DOCX, TXT, XLS, XLSX formats
- 📦 **Archive Support**: ZIP files
- 🎥 **Video Support**: MP4, AVI, MOV formats
- 📊 **File Management**: View uploaded files with metadata (size, upload date)
- ⬇️ **Download**: Download uploaded files
- 🔒 **Security**: File type validation and secure filename handling
- 💾 **Persistent Storage**: Files stored on Amazon EFS for durability and cross-AZ access
- 🚀 **Scalable**: Deployed as Kubernetes deployment with multiple replicas

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Users/Clients │ -> │   LoadBalancer  │ -> │   EKS Cluster   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        |
                                                        v
                                              ┌─────────────────┐
                                              │  Flask App Pods │
                                              │  (Multiple)     │
                                              └─────────────────┘
                                                        |
                                                        v
                                              ┌─────────────────┐
                                              │  EFS Volume     │
                                              │  (/data/uploads)│
                                              └─────────────────┘
```

## Prerequisites

- Amazon EKS cluster
- Amazon EFS file system configured for cross-account access
- EFS CSI driver installed on the cluster
- kubectl configured to access your cluster

## Deployment

### Deploy to Corebank Cluster

```bash
cd applications/unified
./deploy-corebank.sh
```

### Deploy to Satellite Cluster

```bash
cd applications/unified
./deploy-satellite.sh
```

### Test the Deployment

```bash
./test-upload.sh
```

## Configuration

The application uses the following environment variables (configured in the deployment scripts):

- `EFS_ID`: The ID of the EFS file system
- `EFS_ROLE_ARN`: The ARN of the IAM role for EFS access
- `CLUSTER_TYPE`: The type of cluster (corebank/satellite)
- `APP_NAME`: The name of the application instance

## File Upload Specifications

- **Maximum file size**: 16MB per file
- **Supported formats**:
  - Images: PNG, JPG, JPEG, GIF
  - Documents: PDF, DOC, DOCX, TXT, XLS, XLSX
  - Archives: ZIP
  - Videos: MP4, AVI, MOV
- **Storage location**: `/data/uploads` on EFS
- **Filename handling**: Automatic timestamping to prevent conflicts

## API Endpoints

- `GET /` - Main upload interface
- `POST /upload` - File upload endpoint
- `GET /download/<filename>` - File download endpoint
- `GET /health` - Health check endpoint

## Local Development

For local testing and development:

### Using Docker Compose

```bash
# Build and run the application
docker-compose up --build

# Access the application
open http://localhost:8080
```

### Using Python directly

```bash
# Install dependencies
pip install -r requirements.txt

# Create upload directory
mkdir -p /data/uploads

# Run the application
python app.py
```

## Monitoring and Troubleshooting

### Check Application Status

```bash
kubectl get pods -l app=efs-app
kubectl get svc efs-app-service
kubectl get pvc efs-claim
```

### View Logs

```bash
kubectl logs -l app=efs-app -f
```

### Check EFS Mount

```bash
POD_NAME=$(kubectl get pods -l app=efs-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- df -h /data
kubectl exec $POD_NAME -- ls -la /data/uploads/
```

### Port Forward for Local Access

```bash
kubectl port-forward svc/efs-app-service 8080:80
```

Then access the application at `http://localhost:8080`

## Security Considerations

- File type validation prevents execution of malicious files
- Secure filename handling prevents directory traversal attacks
- Files are stored with timestamped names to prevent conflicts
- Maximum file size limits prevent abuse
- Health check endpoint for monitoring

## Cleanup

To remove the application:

```bash
cd applications/unified
./cleanup.sh
```

Or manually:

```bash
kubectl delete deployment efs-file-upload-app
kubectl delete service efs-app-service
kubectl delete ingress efs-app-ingress
kubectl delete pvc efs-claim
kubectl delete configmap file-upload-app
```

## Cross-Account EFS Access

This application is designed to work with cross-account EFS access between:

- **Corebank Account**: Primary EFS owner
- **Satellite Account**: Secondary account with cross-account access

The deployment scripts automatically configure the appropriate IAM roles and EFS settings for each environment.

## Scaling

The application is deployed as a Kubernetes deployment with 2 replicas by default. You can scale it up or down:

```bash
kubectl scale deployment efs-file-upload-app --replicas=5
```

Since files are stored on EFS, all replicas share the same storage, ensuring consistency across multiple instances.
