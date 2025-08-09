# Satellite Account Outputs

# ==============================================
# EKS Cluster Outputs
# ==============================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_oidc_provider_arn" {
  description = "The ARN of the OIDC Identity Provider"
  value       = module.eks.oidc_provider_arn
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_platform_version" {
  description = "Platform version for the EKS cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = module.eks.cluster_status
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by EKS"
  value       = module.eks.cluster_primary_security_group_id
}

output "node_groups" {
  description = "EKS managed node groups"
  value       = module.eks.eks_managed_node_groups
}

# ==============================================
# VPC and Networking Outputs
# ==============================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of CIDR blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets_cidr_blocks" {
  description = "List of CIDR blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = module.vpc.natgw_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

# ==============================================
# Cross-Account VPC Peering Outputs
# ==============================================

output "vpc_peering_connection_accepter_id" {
  description = "VPC peering connection accepter ID"
  value       = aws_vpc_peering_connection_accepter.from_corebank.id
}

output "vpc_peering_connection_accepter_status" {
  description = "Status of the VPC peering connection accepter"
  value       = aws_vpc_peering_connection_accepter.from_corebank.accept_status
}

output "corebank_peering_connection_id" {
  description = "VPC peering connection ID from corebank (input variable)"
  value       = var.corebank_peering_connection_id
}

# ==============================================
# EFS Client Security Group Outputs
# ==============================================

output "efs_client_security_group_id" {
  description = "Security group ID for EFS client access to corebank"
  value       = aws_security_group.efs_client.id
}

output "efs_client_security_group_arn" {
  description = "ARN of the security group for EFS client access to corebank"
  value       = aws_security_group.efs_client.arn
}

# ==============================================
# IAM Role Outputs - EFS CSI Controller
# ==============================================

output "vpc_cni_role_arn" {
  description = "ARN of the IAM role for VPC CNI"
  value       = aws_iam_role.vpc_cni.arn
}

output "vpc_cni_role_name" {
  description = "Name of the IAM role for VPC CNI"
  value       = aws_iam_role.vpc_cni.name
}

output "efs_cross_account_role_arn" {
  description = "ARN of the IAM role for EFS CSI controller cross-account access"
  value       = aws_iam_role.efs_cross_account.arn
}

output "efs_cross_account_role_name" {
  description = "Name of the IAM role for EFS CSI controller cross-account access"
  value       = aws_iam_role.efs_cross_account.name
}

# ==============================================
# IAM Role Outputs - EFS CSI Node
# ==============================================

output "efs_csi_node_role_arn" {
  description = "ARN of the IAM role for EFS CSI Node service account"
  value       = aws_iam_role.efs_csi_node.arn
}

output "efs_csi_node_role_name" {
  description = "Name of the IAM role for EFS CSI Node service account"
  value       = aws_iam_role.efs_csi_node.name
}

# ==============================================
# Cross-Account Access Policy Outputs
# ==============================================

output "assume_corebank_role_policy_arn" {
  description = "ARN of the policy that allows assuming corebank cross-account role"
  value       = aws_iam_policy.assume_corebank_role.arn
}

output "assume_corebank_role_policy_name" {
  description = "Name of the policy that allows assuming corebank cross-account role"
  value       = aws_iam_policy.assume_corebank_role.name
}

# ==============================================
# Kubernetes Secret Outputs
# ==============================================

output "x_account_secret_name" {
  description = "Name of the Kubernetes secret containing cross-account role ARN"
  value       = kubernetes_secret.x_account.metadata[0].name
}

output "x_account_secret_namespace" {
  description = "Namespace of the Kubernetes secret containing cross-account role ARN"
  value       = kubernetes_secret.x_account.metadata[0].namespace
}

output "corebank_cross_account_role_arn" {
  description = "ARN of the cross-account role in corebank account (from secret)"
  value       = kubernetes_secret.x_account.data["awsRoleArn"]
  sensitive   = true
}

# ==============================================
# Account and Region Information
# ==============================================

output "account_id" {
  description = "AWS Account ID where resources are created"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region where resources are created"
  value       = var.aws_region
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = slice(data.aws_availability_zones.available.names, 0, 3)
}

# ==============================================
# Cross-Account Integration Values
# ==============================================

output "corebank_account_id" {
  description = "Corebank account ID for cross-account setup"
  value       = var.corebank_account_id
}

output "corebank_vpc_cidr" {
  description = "Corebank VPC CIDR for cross-account access"
  value       = var.corebank_vpc_cidr
}

output "corebank_efs_id" {
  description = "Corebank EFS file system ID for cross-account access"
  value       = var.corebank_efs_id
}
