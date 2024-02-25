output "dynamodb_table_name" {
  value       = aws_dynamodb_table.lock.name
  sensitive   = true
  description = "name of the Dynamo lock table"
}
output "backend_bucket_arn" {
  value       = aws_s3_bucket.backend.arn
  sensitive   = true
  description = "ARN of the Bucket"
}

output "backend_bucket_name" {
  value       = aws_s3_bucket.backend.id
  sensitive   = true
  description = "Name of the Bucket"
}
