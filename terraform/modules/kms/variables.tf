variable "default_tags" {
  description = "List of default tags to be used for each environment"
  type        = map(string)
}

variable "environment" {
  description = "Environment name used, for example: dev, staging, sandbox, uat, production"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}
