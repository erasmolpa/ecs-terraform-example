
module "backend"{
  source = "../terraform/modules/backend"
  backend = {
    bucket_name    = "terraform-backend-state-incode-demo"
    key            = "state/resource.tfstate"
    region         = "us-east-1"
    dynamodb_table = "resource-backend-lock"
  }
}

module "iam_users"{
  source = "../terraform/modules/iam_users"
}

module "vpc" {
  source = "../terraform/modules/vpc"
}
module "alb" {
  source = "../terraform/modules/alb"

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

module "ecs_cluster" {
  source = "../terraform/modules/ecs_cluster"
}

module "ecs_application" {
  source = "../terraform/modules/ecs_application"
  ecs_task_execution_role = {
    policy_document = {
      actions     = ["sts:AssumeRole"]
      effect      = "Allow"
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    iam_role_name = "task-execution-role"
    iam_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

  ecs_autoscale_role = {
    policy_document = {
      actions     = ["sts:AssumeRole"]
      effect      = "Allow"
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
    iam_role_name = "ecs-scale-application"
    iam_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
  }
  // SEE https://github.com/jvk243/terraform-aws-ecs-postgres-docker-flask-example/blob/main/terraform/task_definition.json.tpl
  ecs_task = {
    family                   = "ecs-task-family"
    container_image_name     = "ghost"
    container_image          = "ghost:alpine"
    container_image_port     = 2368
    cpu                      = 256
    memory                   = 512
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
  }

  ecs_service = {
    name            = "ecs_service"
    cluster         = module.ecs_cluster.aws_ecs_cluster_id
    launch_type     = "FARGATE"
    desired_count   = 3
    egress_all_id   = module.alb.aws_sg_egress_all_id
    private_subnets = module.vpc.vpc_private_subnets_ids
  }

  vpc_id  = module.vpc.vpc_id
  alb_arn = module.alb.aws_alb_arn
}
/**
module "rds-postgres" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
}
**/