# Corebank Account Outputs

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

output "vpc_peering_connection_id" {
  description = "VPC peering connection ID to satellite account"
  value       = aws_vpc_peering_connection.to_satellite.id
}

output "vpc_peering_connection_status" {
  description = "Status of the VPC peering connection to satellite account"
  value       = aws_vpc_peering_connection.to_satellite.accept_status
}

# ==============================================
# EFS Outputs
# ==============================================

output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.main.id
}

output "efs_arn" {
  description = "ARN of the EFS file system"
  value       = aws_efs_file_system.main.arn
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.main.dns_name
}

output "efs_mount_target_ids" {
  description = "List of EFS mount target IDs"
  value       = aws_efs_mount_target.main[*].id
}

output "efs_mount_target_dns_names" {
  description = "List of EFS mount target DNS names"
  value       = aws_efs_mount_target.main[*].dns_name
}

output "efs_mount_target_ip_addresses" {
  description = "List of EFS mount target IP addresses"
  value       = aws_efs_mount_target.main[*].ip_address
}

output "efs_security_group_id" {
  description = "Security group ID for EFS access"
  value       = aws_security_group.efs.id
}

output "efs_creation_token" {
  description = "The creation token for the EFS file system"
  value       = aws_efs_file_system.main.creation_token
}

output "efs_encrypted" {
  description = "Whether the EFS file system is encrypted"
  value       = aws_efs_file_system.main.encrypted
}

output "efs_kms_key_id" {
  description = "The KMS key ID used to encrypt the EFS file system"
  value       = aws_efs_file_system.main.kms_key_id
}

output "efs_performance_mode" {
  description = "The performance mode of the EFS file system"
  value       = aws_efs_file_system.main.performance_mode
}

output "efs_throughput_mode" {
  description = "The throughput mode of the EFS file system"
  value       = aws_efs_file_system.main.throughput_mode
}

output "efs_provisioned_throughput_in_mibps" {
  description = "The provisioned throughput in MiBps for the EFS file system"
  value       = aws_efs_file_system.main.provisioned_throughput_in_mibps
}

# ==============================================
# IAM Role Outputs
# ==============================================

output "vpc_cni_role_arn" {
  description = "ARN of the IAM role for VPC CNI"
  value       = aws_iam_role.vpc_cni.arn
}

output "vpc_cni_role_name" {
  description = "Name of the IAM role for VPC CNI"
  value       = aws_iam_role.vpc_cni.name
}

output "efs_csi_driver_role_arn" {
  description = "ARN of the IAM role for EFS CSI Driver"
  value       = aws_iam_role.efs_csi_driver.arn
}

output "efs_csi_driver_role_name" {
  description = "Name of the IAM role for EFS CSI Driver"
  value       = aws_iam_role.efs_csi_driver.name
}

output "satellite_cross_account_role_arn" {
  description = "ARN of the cross-account role for satellite account access"
  value       = aws_iam_role.satellite_cross_account.arn
}

output "satellite_cross_account_role_name" {
  description = "Name of the cross-account role for satellite account access"
  value       = aws_iam_role.satellite_cross_account.name
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

output "satellite_account_id" {
  description = "Satellite account ID for cross-account setup"
  value       = var.satellite_account_id
}

output "satellite_vpc_id" {
  description = "Satellite VPC ID for peering"
  value       = var.satellite_vpc_id
}

output "satellite_vpc_cidr" {
  description = "Satellite VPC CIDR for cross-account access"
  value       = var.satellite_vpc_cidr
}
