variable "profile" {
  description = "AWS Profile"
  type        = string
  default     = "sre-admin"
}

variable "region" {
  description = "Region for AWS resources"
  type        = string
  default     = "eu-west-1"
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
  type = list(object({
    rulePriority = number
    description  = string
    selection = object({
      tagStatus     = string
      tagPrefixList = optional(list(string))
      countType     = string
      countUnit     = optional(string)
      countNumber   = number
    })
    action = object({
      type = string
    })
  }))
  description = "List of ECR lifecycle policies"
  default = [{
    action = {
      type = "expire"
    }
    description  = "example"
    rulePriority = 1
    selection = {
      countNumber   = 10
      tagPrefixList = [""]
      tagStatus     = "untagged"
      countUnit     = "days",      
      countType     = "imageCountMoreThan"
    }
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
  type        = map(any)
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Logs group for container logs"
  type        = string
  default     = "/ecs/my-app"
}

variable "rds_storage" {
  type        = number
  description = "Size of the RDS database in GB"
}
variable "rds_db_name" {
  type        = string
  description = "Name of the RDS database name"
}

variable "rds_engine" {
  type        = string
  description = "description"
  validation {
    condition     = contains(["postgres", "mysql", "aurora-postgresql", "aurora-mysql"], var.rds_engine)
    error_message = "The following rds_engine are allowed:  postgres,mysql,aurora-postgresql, aurora-mysql"
  }
}

variable "instance_class" {
  type = string
  validation {
    condition     = contains(["db.t3.micro", "db.t2.micro"], var.instance_class)
    error_message = "value"
  }
}

variable "rds_username" {
  type        = string
  sensitive   = true
  description = "name of the database username"
}

variable "rds_password" {
  type        = string
  sensitive   = true
  description = "password of the database username"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "skip_final_snapshot"
}

variable "subnet_group_name" {
  type        = string
  default     = ""
  description = "(Optional) Name of the subnet group"
}
