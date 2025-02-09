output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster."
  value       = module.eks.eks_cluster_oidc_issuer_url
}

output "eks_cluster_security_group_id" {
  description = "The security group ID for the EKS cluster."
  value       = module.eks.eks_cluster_security_group_id
}

output "eks_cluster_serviceaccount_role_arn" {
  description = "The ARN of the IAM role used by service accounts in the EKS cluster."
  value       = module.eks.eks_cluster_serviceaccount_role_arn
}

output "eks_node_group_arn" {
  description = "The ARN of the EKS node group."
  value       = module.eks.eks_node_group_arn
}

output "eks_node_group_role_arn" {
  description = "The ARN of the IAM role used by the EKS node group."
  value       = module.eks.eks_node_group_role_arn
}
