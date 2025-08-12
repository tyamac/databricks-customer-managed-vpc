terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
  backend "s3" {
    bucket       = "<YOUR_BUCKET>"
    region       = "ap-northeast-1"
    profile      = "poc"
    key          = "workspace/terraform.tfstate"
    use_lockfile = true
  }
}
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      project = "databricks"
    }
  }
}