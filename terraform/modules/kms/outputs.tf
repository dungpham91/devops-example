output "kms_arn" {
  description = "KMS key arn"
  value       = aws_kms_key.kms_key.arn
}

output "kms_key_id" {
  description = "KMS key id"
  value       = aws_kms_key.kms_key.key_id
}
