variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  type        = string
}

variable "ecs_task_execution_role" {
  type = object({
    policy_document = object({
      actions     = list(string)
      effect      = string
      type        = string
      identifiers = list(string)
    })
    iam_role_name  = string
    iam_policy_arn = string
  })
}

variable "ecs_task" {
  type = object({
    family                   = string
    container_image_name     = string
    container_image          = string
    cpu                      = number
    memory                   = number
    requires_compatibilities = list(string)
    network_mode             = string
    container_image_port     = number
    environmentFiles         = list(string)
  })
}

variable "ecs_service" {
  type = object({
    name            = string
    cluster         = string
    launch_type     = string
    desired_count   = number
    egress_all_id   = string
    private_subnets = list(string)
  })
}

variable "vpc_id" {
  type = string
}

variable "alb_arn" {
  type = string
}

variable "ecs_autoscale_role" {
  type = object({
    policy_document = object({
      actions     = list(string)
      effect      = string
      type        = string
      identifiers = list(string)
    })
    iam_role_name  = string
    iam_policy_arn = string
  })
}

variable "cloudwatch_metric_alarm_name" {
  description = "Name of the CloudWatch metric alarm"
  type        = string
  default     = "ecs-app-cpu-utilization"
}

variable "cloudwatch_alarm_actions" {
  description = "List of ARNs of the actions to take when the alarm transitions to the ALARM state"
  type        = list(string)
}

variable "cloudwatch_metric_alarm_cpu_utilization_threshold" {
  description = "Threshold for CPU utilization in percentage for the CloudWatch metric alarm"
  type        = number
  default     = 80
}

variable "cloudwatch_metric_alarm_memory_utilization_threshold" {
  description = "Threshold for memory utilization in percentage for the CloudWatch metric alarm"
  type        = number
  default     = 80
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Logs group for container logs"
  type        = string
  default     = "/ecs/my-app"
}
