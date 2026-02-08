############################################################
# Provider Configuration
############################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

############################################################
# VPC — Multi-AZ
############################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0"

  name = "swimlane-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

############################################################
# EKS Cluster — Multi-AZ Active-Active
############################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0"

  cluster_name    = "swimlane-eks"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 5
      desired_size = 2
    }
  }
}

############################################################
# MongoDB Secrets — AWS Secrets Manager
############################################################

resource "aws_secretsmanager_secret" "mongo" {
  name = "swimlane-mongo-credentials"
}

resource "aws_secretsmanager_secret_version" "mongo_version" {
  secret_id = aws_secretsmanager_secret.mongo.id

  secret_string = jsonencode({
    username = "admin"
    password = "password"
    database = "noobjs_dev"
  })
}

############################################################
# IAM Role for Pod Access (IRSA)
############################################################

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.0"

  role_name = "swimlane-secrets-role"

  attach_secretsmanager_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn

      namespace_service_accounts = [
        "default:swimlane-app"
      ]
    }
  }
}

############################################################
# Outputs
############################################################

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "mongo_secret_arn" {
  value = aws_secretsmanager_secret.mongo.arn
}
