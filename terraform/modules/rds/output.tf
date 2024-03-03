output "db_instance_id" {
  value       = aws_db_instance.golang_serverless_db.id
  description = "RDS ID"
}

output "db_name" {
  value = aws_db_instance.golang_serverless_db.db_name
}

output "db_address" {
  value = aws_db_instance.golang_serverless_db.address
}

output "db_port" {
  value = aws_db_instance.golang_serverless_db.port
}
