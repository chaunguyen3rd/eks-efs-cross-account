# Satellite Account Variables

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "satellite"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "banking-platform"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
}

variable "corebank_account_id" {
  description = "AWS Account ID for corebank account"
  type        = string
}

variable "corebank_vpc_cidr" {
  description = "CIDR block for corebank VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "corebank_peering_connection_id" {
  description = "VPC peering connection ID from corebank account"
  type        = string
}

variable "corebank_efs_id" {
  description = "EFS file system ID from corebank account"
  type        = string
}
