variable "profile" {
  description = "AWS Profile"
  type        = string
  default     = "erasmo-sre-admin"
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
  default = {
    name                 = "ecs-vpc"
    cidr_block           = "10.0.0.0/16"
    azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
    private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    enable_ipv6          = true
    enable_nat_gateway   = true
    enable_vpn_gateway   = true
    enable_dns_hostnames = false
    enable_dns_support   = false
  }
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "dev"
    Project     = "incode-challenge"
    Component   = "vpc"
  }
}

/***
** BACKEND STATE
**/
variable "backend" {
  type = object({
    bucket_name    = string
    key            = string
    region         = string
    dynamodb_table = string
  })
  default = {
    bucket_name    = "backend"
    key            = "state/resource.tfstate"
    region         = "us-east-1"
    dynamodb_table = "resource-backend-lock"
  }
}