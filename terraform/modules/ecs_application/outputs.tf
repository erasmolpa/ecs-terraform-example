output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.ecs_task.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.ecs_service.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.ecs_service.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.ecs_task_execution_role.iam_role_arn
}

output "ecs_autoscale_role_arn" {
  description = "ARN of the ECS autoscale role"
  value       = module.ecs_autoscale_role.iam_role_arn
}

output "ecs_cpu_utilization_alarm_arn" {
  description = "ARN of the CPU utilization alarm in ECS"
  value       = aws_cloudwatch_metric_alarm.ecs_cpu_utilization_alarm.arn
}

output "ecs_memory_utilization_alarm_arn" {
  description = "ARN of the memory utilization alarm in ECS"
  value       = aws_cloudwatch_metric_alarm.ecs_memory_utilization_alarm.arn
}
