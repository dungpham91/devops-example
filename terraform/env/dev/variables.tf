variable "access_entry_type" {
  description = "Type of access entry (STANDARD, EC2, EC2_LINUX, EC2_WINDOWS, FARGATE_LINUX)"
  type        = string
  default     = "STANDARD"
}

variable "access_scope_type" {
  description = "Type of access scope (namespace or cluster)"
  type        = string
  default     = "cluster"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "custom_ami_id" {
  description = "Custom AMI ID for EKS nodes"
  type        = string
  default     = "ami-03f70ec274de537b5" # amazon-eks-node-al2023-x86_64-standard-1.32-v20250203
}

variable "default_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Provisioner = "terraform"
    Project     = "devopslite"
  }
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "kubernetes_groups" {
  description = "List of Kubernetes groups to grant access to the EKS cluster"
  type        = list(string)
  default     = ["admin"]
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_desired_capacity" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 3
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 8
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 3
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "ng"
}

variable "node_instance_type" {
  description = "Instance type for the EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "policy_arn" {
  description = "ARN of the IAM policy to associate with the principal"
  type        = string
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "principal_arn" {
  description = "ARN of the principal to grant access to the EKS cluster"
  type        = string
  default     = null
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24"]
}

variable "project" {
  type    = string
  default = "devopslite"
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}
