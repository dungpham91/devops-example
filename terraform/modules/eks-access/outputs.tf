output "eks_access_entry_arn" {
  description = "The ARN of the EKS access entry."
  value       = aws_eks_access_entry.eks_access_entry.access_entry_arn
}

output "eks_access_entry_principal_arn" {
  description = "The ARN of the principal associated with the EKS access entry."
  value       = aws_eks_access_entry.eks_access_entry.principal_arn
}

output "eks_access_entry_type" {
  description = "The type of access entry."
  value       = aws_eks_access_entry.eks_access_entry.type
}
