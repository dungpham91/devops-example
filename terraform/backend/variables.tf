variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "project" {
  description = "The project name to use for unique resource naming"
  default     = "devopslite"
  type        = string
}

variable "default_tags" {
  type = map(string)
  default = {
    Provisioner = "terraform"
    Project     = "devopslite"
  }
}
