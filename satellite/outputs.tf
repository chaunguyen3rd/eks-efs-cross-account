# # Satellite Account Outputs

# output "cluster_name" {
#   description = "Name of the EKS cluster"
#   value       = module.eks.cluster_name
# }

# output "cluster_endpoint" {
#   description = "Endpoint for EKS control plane"
#   value       = module.eks.cluster_endpoint
# }

# output "cluster_security_group_id" {
#   description = "Security group ID attached to the EKS cluster"
#   value       = module.eks.cluster_security_group_id
# }

# output "cluster_oidc_issuer_url" {
#   description = "The URL on the EKS cluster OIDC Issuer"
#   value       = module.eks.cluster_oidc_issuer_url
# }

# output "cluster_version" {
#   description = "The Kubernetes version for the EKS cluster"
#   value       = module.eks.cluster_version
# }

# output "cluster_platform_version" {
#   description = "Platform version for the EKS cluster"
#   value       = module.eks.cluster_platform_version
# }

# output "cluster_status" {
#   description = "Status of the EKS cluster"
#   value       = module.eks.cluster_status
# }

# output "cluster_certificate_authority_data" {
#   description = "Base64 encoded certificate data required to communicate with the cluster"
#   value       = module.eks.cluster_certificate_authority_data
# }

# output "vpc_id" {
#   description = "ID of the VPC"
#   value       = module.vpc.vpc_id
# }

# output "vpc_cidr_block" {
#   description = "The CIDR block of the VPC"
#   value       = module.vpc.vpc_cidr_block
# }

# output "private_subnets" {
#   description = "List of IDs of private subnets"
#   value       = module.vpc.private_subnets
# }

# output "public_subnets" {
#   description = "List of IDs of public subnets"
#   value       = module.vpc.public_subnets
# }

# output "vpc_cni_role_arn" {
#   description = "ARN of the IAM role for VPC CNI"
#   value       = aws_iam_role.vpc_cni.arn
# }

# output "efs_client_security_group_id" {
#   description = "Security group ID for EFS client"
#   value       = aws_security_group.efs_client.id
# }

# output "node_groups" {
#   description = "EKS node groups"
#   value       = module.eks.eks_managed_node_groups
# }

# output "efs_cross_account_role_arn" {
#   description = "ARN of the IAM role for cross-account EFS access (supports both controller and node service accounts)"
#   value       = aws_iam_role.efs_cross_account.arn
# }
