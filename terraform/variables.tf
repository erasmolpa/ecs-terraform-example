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
