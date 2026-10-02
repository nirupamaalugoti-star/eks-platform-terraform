terraform {
  required_version = ">= 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # backend "s3" {} # configure remote state: bucket, key, region, dynamodb_table for locking
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source   = "../../modules/vpc"
  name     = "${var.project}-${var.environment}"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "${var.project}-${var.environment}"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  node_instance_type = "t3.medium"
  desired_size    = 2
}

module "irsa" {
  source            = "../../modules/iam-irsa"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}

module "rds" {
  source          = "../../modules/rds"
  identifier      = "${var.project}-${var.environment}"
  private_subnets = module.vpc.private_subnet_ids
  vpc_id          = module.vpc.vpc_id
  eks_sg_id       = module.eks.node_security_group_id
}
