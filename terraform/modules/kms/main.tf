data "aws_caller_identity" "current" {}

resource "aws_kms_key" "kms_key" {
  description             = "KMS key used to encrypt data for all services in this demo"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project}-${var.environment}-kms-key"
    }
  )
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.project}-${var.environment}-kms-key"
  target_key_id = aws_kms_key.kms_key.key_id
}

resource "aws_kms_key_policy" "kms_key_policy" {
  key_id = aws_kms_key.kms_key.key_id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow administration of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/cloud_user"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/cloud_user",
          Service = [
            "ec2.amazonaws.com",
            "ecr.amazonaws.com",
            "eks.amazonaws.com",
            "logs.amazonaws.com",
            "vpc-flow-logs.amazonaws.com",
            "waf.amazonaws.com",
            "waf-regional.amazonaws.com",
          ]
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })
}
