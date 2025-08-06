#!/bin/bash

echo "=== Checking EFS CSI Driver Installation ==="

# Check if EFS CSI driver is installed
echo "Checking for EFS CSI driver pods..."
kubectl get pods -n kube-system | grep efs-csi || echo "No EFS CSI driver pods found"

echo ""
echo "Checking EFS CSI driver DaemonSet..."
kubectl get daemonset -n kube-system | grep efs-csi || echo "No EFS CSI DaemonSet found"

echo ""
echo "Checking EFS CSI driver Deployment..."
kubectl get deployment -n kube-system | grep efs-csi || echo "No EFS CSI Deployment found"

echo ""
echo "Checking EFS CSI driver service account..."
kubectl get serviceaccount -n kube-system | grep efs-csi || echo "No EFS CSI service account found"

echo ""
echo "Checking StorageClass..."
kubectl get storageclass efs-sc || echo "StorageClass efs-sc not found"

echo ""
echo "Checking CSI drivers..."
kubectl get csidriver | grep efs || echo "No EFS CSI driver found"

echo ""
echo "=== EFS CSI Controller Service Account Details ==="
kubectl describe serviceaccount efs-csi-controller-sa -n kube-system 2>/dev/null || echo "Service account efs-csi-controller-sa not found in kube-system namespace"

echo ""
echo "=== Available Service Accounts in kube-system ==="
kubectl get serviceaccount -n kube-system | grep efs

echo ""
echo "=== EFS CSI Driver Installation Status ==="
helm list -n kube-system | grep efs || echo "No EFS CSI driver Helm release found"
