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


variable "backend" {
  description = "Variables for backend module"
  type        = map(any)
}
variable "aws_ecr_repository" {
  description = "The name of the ECR repository"
  type        = string
  default     = "aws_repository_workshop"
}

variable "aws_ecr_repository_lifecycle_policy_rules" {
  description = "List of lifecycle policy rules for the repository"
  type = list(object({
    rulePriority = number
    description  = string
    selection = object({
      tagStatus     = string
      tagPrefixList = list(string)
      countType     = string
      countNumber   = number
    })
    action = object({
      type = string
    })
  }))
  default = [{
    action = {
      type = "expire"
    }
    description = "example"
    rulePriority = 1
    selection = {
      countNumber = 10
      tagPrefixList = []
      tagStatus = "untagged"
      countType = "imageCountMoreThan"
    }
  } ]
}
variable "vpc" {
  type = object({
    name                 = string
    cidr_block           = string
    azs                  = list(string)
    private_subnets      = list(string)
    public_subnets       = list(string)
    enable_ipv6          = bool
    enable_nat_gateway   = bool
    enable_vpn_gateway   = bool
    enable_dns_hostnames = bool
    enable_dns_support   = bool
  })
}


variable "alb" {
  type = object({
    name               = string
    internal           = bool
    load_balancer_type = string
    subnets            = list(string)
  })
}

variable "ecs_cluster" {
  description = "Variables for ECS cluster module"
  type        = map(any)
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Logs group for container logs"
  type        = string
  default     = "/ecs/my-app"
}
