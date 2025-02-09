terraform {
  backend "s3" {
    bucket         = "devopslite-dev-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devopslite-tf-state"
  }
}
