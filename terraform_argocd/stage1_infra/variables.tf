variable "aws_region" {
  type        = string
  description = "AWS region to deploy EKS"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI named profile"
}

variable "key_name" {
  type        = string
  description = "Name for SSH key pair"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones to use"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "node_desired" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "node_min" {
  type        = number
  description = "Minimum number of worker nodes"
}

variable "node_max" {
  type        = number
  description = "Maximum number of worker nodes"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for nodes"
}

variable "tags" {
  type = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
  description = "Tags to apply to resources"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the worker nodes"
}

variable "github_repo_url" {
  description = "The URL of the GitHub repository to clone"
  type        = string
}

variable "iam_role_name" {
  description = "IAM role name for EC2 instance"
  type        = string
}

variable "policy_arn" {
  description = "IAM policy ARN"
  type        = string
}

variable "cluster_dns" {
  description = "Base DNS for the cluster"
  type        = string
  default     = "example.com" # Replace with actual DNS if using Route53 or external access
}