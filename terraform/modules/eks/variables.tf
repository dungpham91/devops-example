variable "custom_ami_id" {
  description = "Custom AMI ID for EKS nodes"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt secrets"
  type        = string
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS node group (ON_DEMAND or SPOT)"
  type        = string
}

variable "node_group_desired_capacity" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_instance_type" {
  description = "Instance type for the EKS nodes"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster and node group"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs for the EKS cluster and node group"
  type        = list(string)
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
