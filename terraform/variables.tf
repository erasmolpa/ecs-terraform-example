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
  type        = map
}
variable "aws_ecr_repository" {
  description = "The name of the ECR repository"
  type        = string
  default     = "aws_repository_workshop"
}

variable "aws_ecr_repository_lifecycle_policy_rules" {
  description = "List of lifecycle policy rules for the repository"
  type = list(object({
    rule_priority         = number
    description           = string
    tag_prefix_list       = list(string)
    count_type            = string
    count_number          = number
    action_type           = string
    action_type_parameter = string
  }))
  default = [
    {
      rule_priority         = 1
      description           = "keep last 10 images"
      tag_prefix_list       = []
      count_type            = "imageCountMoreThan"
      count_number          = 10
      action_type           = "expire"
      action_type_parameter = ""
    }
  ]
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
  type        = map
}
