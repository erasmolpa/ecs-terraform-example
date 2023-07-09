// THIS https://aws.plainenglish.io/into-the-fargate-with-terraform-1a45ea51707d

module "backend"{
  source = "modules/backend"
  backend = {
    bucket_name    = "terraform-backend-state-incode-demo"
    key            = "state/resource.tfstate"
    region         = "us-east-1"
    dynamodb_table = "resource-backend-lock"
  }
}

//Steps https://github.com/jvk243/terraform-aws-ecs-postgres-docker-flask-example/tree/main
module "iam-users"{
  source = "modules/iam-users"
}

module "vpc" {
  source = "modules/vpc"
}
module "alb" {
  source = "modules/alb"

  aws_security_group_http = {
    name        = "http"
    description = "HTTP traffic"
    vpc_id      = module.vpc.vpc_id
  }

  aws_security_group_egress_all = {
    name        = "egress-all"
    description = "Allow all outbound traffic"
    vpc_id      = module.vpc.vpc_id
  }
  alb = {
    name               = "alb-test"
    internal           = false
    load_balancer_type = "application"
    subnets            = module.vpc.vpc_public_subnets_ids
  }
}

module "fargate-cluster" {
  source = "modules/ecs_cluster"
}

/**
module "rds-postgres" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
}
**/