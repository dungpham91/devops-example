output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.tf_state_bucket.bucket
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.tf_state_bucket.arn
}

output "dynamodb_name" {
  description = "DynamoDB name"
  value       = aws_dynamodb_table.terraform_dynamodb_table.name
}
