terraform {
  backend "s3" {
    bucket         = var.backend.bucket_name
    key            = var.backend.key
    region         = var.backend.region
    encrypt        = true
    dynamodb_table = var.backend.dynamodb_table
  }
}