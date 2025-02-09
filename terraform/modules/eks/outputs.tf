output "eks_cluster_certificate_authority_data" {
  description = "The certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = aws_security_group.eks_node_sg.id
}

output "eks_cluster_serviceaccount_role_arn" {
  description = "ARN of the IAM role used by EKS service account"
  value       = aws_iam_role.eks_cluster_serviceaccount_role.arn
}

output "eks_node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.eks_node_group.arn
}

output "eks_node_group_role_arn" {
  description = "ARN of the IAM role used by EKS node group"
  value       = aws_iam_role.eks_node_group_role.arn
}
