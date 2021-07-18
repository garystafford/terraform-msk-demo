terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

terraform {
  backend "s3" {
    bucket = "terrform-us-east-1-676164205626"
    key    = "lab/terraform.tfstate"
    region = "us-east-1"
  }
}
