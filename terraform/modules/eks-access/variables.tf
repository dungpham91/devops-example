variable "access_entry_type" {
  description = "Type of access entry (STANDARD, EC2, EC2_LINUX, EC2_WINDOWS, FARGATE_LINUX)"
  type        = string
}

variable "access_scope_type" {
  description = "Type of access scope (namespace or cluster)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "kubernetes_groups" {
  description = "List of Kubernetes groups to grant access to the EKS cluster"
  type        = list(string)
}

variable "policy_arn" {
  description = "ARN of the IAM policy to associate with the principal"
  type        = string
}

variable "principal_arn" {
  description = "ARN of the principal to grant access to the EKS cluster"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}
