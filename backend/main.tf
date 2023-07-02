terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.18.0"
    }
  }

  backend "s3" {
    bucket         	   = var.bucket_name
    key                = "state/terraform.tfstate"
    region         	   = var.region
    encrypt        	   = true
    dynamodb_table     = var.dynamodb_table
  }
}