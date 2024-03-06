profile = "cqs-sre"
region  = "eu-west-1"

backend = {
  bucket_name    = "terraform-backend-state-incode-demo"
  key            = "state/resource.tfstate"
  region         = "eu-west-1"
  dynamodb_table = "resource-backend-lock"
}

aws_ecr_repository = "repository-docker"

aws_ecr_repository_lifecycle_policy_rules = [{
  action = {
    type = "expire"
  }
  description  = "Retain at least 3 images and images younger than 180 days"
  rulePriority = 1
  selection = {
    countNumber   = 10
    tagPrefixList = [""]
    tagStatus     = "any"
    countType     = "imageCountMoreThan"
  }
  },
  {
    action = {
      type = "expire"
    }
    description  = "Expire images older than 14 days"
    rulePriority = 2
    selection = {
      countNumber   = 10
      tagPrefixList = [""]
      tagStatus     = "any"
      countType     = "sinceImagePushed"
      countUnit     = "days"
    }
}]

vpc = {
  name                 = "ecs-vpc"
  cidr_block           = "10.0.0.0/16"
  azs                  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_ipv6          = false
  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

ecs_cluster = {
  name = "fargate-cluster"
}

alb = {
  name               = "alb-test"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

rds_storage         = 10
rds_db_name         = "dbexample"
rds_engine          = "mysql"
instance_class      = "db.t2.micro"
skip_final_snapshot = true
