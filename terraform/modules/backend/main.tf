resource "aws_s3_bucket" "backend" {
  bucket = "${var.backend.bucket_name}-tf-learn"
  lifecycle {
    prevent_destroy = true
  }
}

# resource "aws_s3_bucket_acl" "backend" {
#   bucket = aws_s3_bucket.backend.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id

  versioning_configuration {
    status = "${var.backend.versioning_configuration}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = aws_s3_bucket.backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.backend.bucket_sse_algorithm
    }
  }
}
resource "aws_s3_bucket_public_access_block" "backend" {
  bucket = aws_s3_bucket.backend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "lock" {
  name           = "${var.backend.dynamodb_table}-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}