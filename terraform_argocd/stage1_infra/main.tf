terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0, < 3.0.0"
    }
    # … other providers …
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    aws = {
      source  = "hashicorp/aws"
    }
  }
}


provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "tls_private_key" "eks_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.eks_key.public_key_openssh
}

resource "local_file" "pem_file" {
  content         = tls_private_key.eks_key.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eks-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = var.tags
}

resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Allow SSH access to EKS nodes"
  vpc_id      = module.vpc.vpc_id
  

  ingress {
    description = "SSH from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id



# enable both public & private API endpoints:
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = true

  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  eks_managed_node_groups = {
    workers = {
      desired_capacity = var.node_desired
      max_capacity     = var.node_max
      min_capacity     = var.node_min

      instance_types  = [var.instance_type]
      capacity_type   = "ON_DEMAND"
      key_name        = aws_key_pair.eks_key_pair.key_name
      security_groups = [aws_security_group.eks_node_sg.id]

      tags = {
        Name = "eks-node"
      }
    }
  }

  tags = var.tags
}