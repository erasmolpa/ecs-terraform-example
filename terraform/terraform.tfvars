profile = "sre-admin"
region  = "us-east-1"

vpc = {
  name                 = "ecs-vpc"
  cidr_block           = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_ipv6          = false
  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

alb = {
  name               = "alb-test"
  internal           = false
  load_balancer_type = "application"
}


ecs_cluster = {
  name = "fargate-cluster"
}

ecs_application = {
  ecs_task_execution_role = {
    iam_role_name  = "task-execution-role"
    iam_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

  ecs_autoscale_role = {
    iam_role_name  = "ecs-scale-application"
    iam_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
  }

  ecs_task = {
    family                   = "ecs-task-family"
    container_image_name     = "serverless-go-app"
    container_image          = "510330021658.dkr.ecr.us-east-1.amazonaws.com/serverless-go-app:latest"
    container_image_port     = 80
    cpu                      = 256
    memory                   = 512
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
  }

  ecs_service = {
    name            = "ecs_service"
    launch_type     = "FARGATE"
    desired_count   = 3
  }
}

backend = {
  bucket_name    = "terraform-backend-state-incode-demo"
  key            = "state/resource.tfstate"
  region         = "us-east-1"
  dynamodb_table = "resource-backend-lock"
}

aws_ecr_repository = {
  repository_name = "repository_workshop_serverless_app"
  lifecycle_policy_rules = [
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
