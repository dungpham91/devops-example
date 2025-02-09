variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "default_tags" {
  description = "List of default tags to be used for each environment"
  type        = map(string)
}

variable "environment" {
  description = "Environment name used, for example: dev, staging, sandbox, uat, production"
  type        = string
}

variable "private_subnets_cidr" {
  description = "List of CIDRs used for private subnets"
  type        = list(string)
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDRs used for public subnets"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "The CDIR block used for the VPC"
  type        = string
}
