#!/bin/bash

# Test script for EFS File Upload Application
# This script helps test the file upload functionality

set -e

echo "🧪 EFS File Upload Application Test Script"
echo "=========================================="

# Check if the application is running
echo "1. Checking application status..."
kubectl get pods -l app=efs-app
kubectl get svc efs-app-service

# Get the service endpoint
SERVICE_ENDPOINT=$(kubectl get svc efs-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending")

if [ "$SERVICE_ENDPOINT" = "pending" ] || [ -z "$SERVICE_ENDPOINT" ]; then
    echo "⚠️  LoadBalancer endpoint not ready yet. Checking NodePort..."
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}' 2>/dev/null || echo "not-available")
    NODE_PORT=$(kubectl get svc efs-app-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "not-available")
    
    if [ "$NODE_IP" != "not-available" ] && [ "$NODE_PORT" != "not-available" ]; then
        SERVICE_ENDPOINT="$NODE_IP:$NODE_PORT"
        echo "✅ Using NodePort: http://$SERVICE_ENDPOINT"
    else
        echo "⚠️  Service endpoint not available yet. Use port-forward:"
        echo "    kubectl port-forward svc/efs-app-service 8080:80"
        echo "    Then access: http://localhost:8080"
        SERVICE_ENDPOINT="localhost:8080"
    fi
else
    echo "✅ LoadBalancer endpoint: http://$SERVICE_ENDPOINT"
fi

echo ""
echo "2. Testing health endpoint..."
if command -v curl >/dev/null 2>&1; then
    echo "Attempting to reach health endpoint..."
    curl -s "http://$SERVICE_ENDPOINT/health" || echo "❌ Health check failed (service may not be ready)"
else
    echo "ℹ️  curl not available. Install curl to test endpoints automatically."
fi

echo ""
echo "3. Checking EFS mount and storage..."
POD_NAME=$(kubectl get pods -l app=efs-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$POD_NAME" ]; then
    echo "✅ Found pod: $POD_NAME"
    echo "Checking EFS mount..."
    kubectl exec "$POD_NAME" -- df -h /data || echo "❌ Failed to check EFS mount"
    
    echo "Checking upload directory..."
    kubectl exec "$POD_NAME" -- ls -la /data/uploads/ || echo "ℹ️  Upload directory not yet created (normal on first run)"
else
    echo "❌ No pods found with label app=efs-app"
fi

echo ""
echo "4. Application logs (last 10 lines)..."
if [ -n "$POD_NAME" ]; then
    kubectl logs "$POD_NAME" --tail=10 || echo "❌ Failed to get logs"
else
    echo "❌ No pod available for logs"
fi

echo ""
echo "📋 Quick Reference Commands:"
echo "  • View all resources: kubectl get all -l app=efs-app"
echo "  • Stream logs: kubectl logs -l app=efs-app -f"
echo "  • Shell into pod: kubectl exec -it \$(kubectl get pods -l app=efs-app -o name | head -1) -- /bin/bash"
echo "  • Port forward: kubectl port-forward svc/efs-app-service 8080:80"
echo "  • Check EFS files: kubectl exec \$(kubectl get pods -l app=efs-app -o name | head -1) -- ls -la /data/uploads/"

echo ""
echo "🌐 Access the application:"
if [ "$SERVICE_ENDPOINT" = "localhost:8080" ]; then
    echo "  Run: kubectl port-forward svc/efs-app-service 8080:80"
    echo "  Then visit: http://localhost:8080"
else
    echo "  URL: http://$SERVICE_ENDPOINT"
fi

echo ""
echo "📁 File Upload Features:"
echo "  • Supported formats: Images (PNG, JPG, JPEG, GIF), Documents (PDF, DOC, DOCX, TXT, XLS, XLSX), Archives (ZIP), Videos (MP4, AVI, MOV)"
echo "  • Max file size: 16MB per file"
echo "  • Multiple file upload support"
echo "  • File download functionality"
echo "  • Persistent storage on EFS"
