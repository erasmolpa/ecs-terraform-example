variable "profile" {
  description = "AWS Profile"
  type        = string
  default     = "sre-admin"
}

variable "region" {
  description = "Region for AWS resources"
  type        = string
  default     = "us-east-1"
}
variable "vpc" {
  description = "Variables for VPC module"
  type        = map
}

variable "alb" {
  description = "Variables for ALB module"
  type        = map
  default     = {
    name               = "alb-test"
    internal           = false
    load_balancer_type = "application"
  }
}

variable "ecs_cluster" {
  description = "Variables for ECS cluster module"
  type        = map
  default     = {
    name = "fargate-cluster"
  }
}

variable "ecs_application" {
  description = "Variables for ECS application module"
  type        = map
}

variable "backend" {
  description = "Variables for backend module"
  type        = map
}

variable "aws_ecr_repository" {
  description = "Variables for AWS ECR repository module"
  type        = map
}