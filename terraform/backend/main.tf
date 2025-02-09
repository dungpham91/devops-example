terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.86.0"
    }
  }

  backend "s3" {
    bucket         = "devopslite-dev-tf-state"
    key            = "s3-backend/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devopslite-tf-state"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tf_state_bucket" {
  bucket        = "${var.project}-dev-tf-state"
  force_destroy = true

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project}-dev-tf-state"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "tf_bucket_public_access_block" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "tf_bucket_ownership_controls" {
  depends_on = [
    aws_s3_bucket.tf_state_bucket
  ]

  bucket = aws_s3_bucket.tf_state_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "tf_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_bucket_encryption" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.tf_kms_key.arn
    }
  }
}

resource "aws_kms_key" "tf_kms_key" {
  description             = "The KMS key is used to encrypt the S3 bucket as a backend for terraform"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  tags = merge(
    var.default_tags,
    {
      Name   = "${var.project}-tf-state-key"
      Bucket = aws_s3_bucket.tf_state_bucket.arn
    }
  )
}

resource "aws_kms_alias" "tf_kms_key_alias" {
  name          = "alias/${var.project}-${var.region}-kms-key"
  target_key_id = aws_kms_key.tf_kms_key.key_id
}

resource "aws_kms_key_policy" "tf_kms_key_policy" {
  key_id = aws_kms_key.tf_kms_key.key_id

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
            "s3.amazonaws.com",
            "dynamodb.amazonaws.com"
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

resource "aws_dynamodb_table" "terraform_dynamodb_table" {
  name         = "${var.project}-tf-state"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.tf_kms_key.arn
  }

  tags = merge(
    var.default_tags,
    {
      Name   = "${var.project}-tf-state"
      Bucket = aws_s3_bucket.tf_state_bucket.arn
    }
  )
}
