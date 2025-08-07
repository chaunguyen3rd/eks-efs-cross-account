# Satellite Account - Main Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      Account     = "satellite"
      ManagedBy   = "terraform"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile]
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

# VPC Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-satellite-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-satellite-eks"
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      k8s_labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }
    }
  }

  # Enable IRSA
  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.vpc_cni.arn
    }
    aws-efs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.efs_cross_account.arn
    }
  }
}

# IAM Role for VPC CNI
resource "aws_iam_role" "vpc_cni" {
  name = "${var.project_name}-satellite-vpc-cni-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-node"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-satellite-vpc-cni-role"
  }
}

# Attach AWS managed policy for VPC CNI
resource "aws_iam_role_policy_attachment" "vpc_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni.name
}

# Accept VPC peering connection from corebank
resource "aws_vpc_peering_connection_accepter" "from_corebank" {
  vpc_peering_connection_id = var.corebank_peering_connection_id
  auto_accept               = true

  tags = {
    Name = "${var.project_name}-satellite-accept-peering"
  }
}

# Route table entries for peering connection
resource "aws_route" "private_to_corebank" {
  count                     = length(module.vpc.private_route_table_ids)
  route_table_id            = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.corebank_vpc_cidr
  vpc_peering_connection_id = var.corebank_peering_connection_id

  depends_on = [aws_vpc_peering_connection_accepter.from_corebank]
}

resource "aws_route" "public_to_corebank" {
  count                     = length(module.vpc.public_route_table_ids)
  route_table_id            = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block    = var.corebank_vpc_cidr
  vpc_peering_connection_id = var.corebank_peering_connection_id

  depends_on = [aws_vpc_peering_connection_accepter.from_corebank]
}

# Security group for EFS access to corebank
resource "aws_security_group" "efs_client" {
  name_prefix = "${var.project_name}-efs-client-"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "NFS to corebank EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.corebank_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-efs-client-sg"
  }
}

# IAM Role for Cross-Account EFS Access
resource "aws_iam_role" "efs_cross_account" {
  name = "${var.project_name}-satellite-efs-cross-account-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:efs-csi-controller-sa"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-satellite-efs-cross-account-role"
  }
}

# Attach AWS managed policy for EFS CSI Driver
resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_cross_account.name
}

# Additional policy for cross-account EFS access
resource "aws_iam_policy" "efs_cross_account_policy" {
  name        = "${var.project_name}-satellite-efs-cross-account-policy"
  description = "Policy for cross-account EFS access from satellite to corebank"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets"
        ]
        Resource = "arn:aws:efs:${var.aws_region}:${var.corebank_account_id}:file-system/${var.corebank_efs_id}"
      }
    ]
  })
}

# Attach the cross-account policy to the role
resource "aws_iam_role_policy_attachment" "efs_cross_account" {
  role       = aws_iam_role.efs_cross_account.name
  policy_arn = aws_iam_policy.efs_cross_account_policy.arn
}

# IAM Role for EFS Application Service Account
resource "aws_iam_role" "efs_app" {
  name = "${var.project_name}-satellite-efs-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:default:efs-app-sa"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-satellite-efs-app-role"
  }
}

# Attach the cross-account policy to the app role as well
resource "aws_iam_role_policy_attachment" "efs_app" {
  role       = aws_iam_role.efs_app.name
  policy_arn = aws_iam_policy.efs_cross_account_policy.arn
}
