# 4 Create task application
# 4.1 Create Need VPC
# 4.2 Create Load Balancer
# 4.3 Create Cluster
# 4.4 Create RDS
# 4.5 Create Task application with config (rds)
# 5 Provide read access to IAM Users

# Separate Cluster Creation https://blog.knoldus.com/how-to-use-data-source-in-terraform/
# Golang connect to RDS https://docs.aws.amazon.com/code-library/latest/ug/go_2_rds_code_examples.html
# Localstack https://docs.localstack.cloud/user-guide/aws/rds/  

module "vpc" {
  source = "../terraform/modules/vpc"
  vpc    = var.vpc
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
  depends_on = [module.vpc]
}

module "ecs_cluster" {
  source = "../terraform/modules/ecs_cluster"
  name   = var.ecs_cluster["name"]
}

module "rds_application" {
  source              = "../terraform/modules/rds"
  rds_db_name         = var.rds_db_name
  rds_engine          = var.rds_engine
  rds_storage         = var.rds_storage
  instance_class      = var.instance_class
  rds_username        = var.rds_username
  rds_password        = var.rds_password
  skip_final_snapshot = var.skip_final_snapshot
}

module "ecs_application" {
  source     = "../terraform/modules/ecs_application"
  vpc_id     = module.vpc.vpc_id
  alb_arn    = module.alb.aws_alb_arn
  aws_region = var.region
  ecs_task_execution_role = {
    policy_document = {
      actions     = ["sts:AssumeRole"]
      effect      = "Allow"
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    iam_role_name  = "task-execution-role"
    iam_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  }

  ecs_autoscale_role = {
    policy_document = {
      actions     = ["sts:AssumeRole"]
      effect      = "Allow"
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
    iam_role_name  = "ecs-scale-application"
    iam_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
  }

  ecs_task = {
    family                   = "ecs-task-family"
    container_image_name     = "serverless-go-app"
    container_image          = "${module.aws_ecr_repository.repository_url}:latest"
    container_image_port     = 80
    cpu                      = 256
    memory                   = 512
    requires_compatibilities = ["FARGATE"]
    network_mode             = "awsvpc"
    log_configuration = {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = var.cloudwatch_log_group_name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    },
    environment = [
      {
        name  = "DB_ADDRESS"
        value = module.rds_application.db_address
      },
      {
        name  = "DB_NAME"
        value = module.rds_application.db_name
      },
      {
        name  = "DB_PORT"
        value = module.rds_application.db_port
      },
      {
        name  = "DB_DRIVER"
        value = var.rds_engine
      },
      {
        name  = "DB_USERNAME"
        value = var.rds_username
      },
      {
        name  = "DB_PASSWORD"
        value = var.rds_password
      }
    ]
  }

  ecs_service = {
    name            = "ecs_service"
    cluster         = module.ecs_cluster.aws_ecs_cluster_id
    launch_type     = "FARGATE"
    desired_count   = 3
    egress_all_id   = module.alb.aws_sg_egress_all_id
    private_subnets = module.vpc.vpc_private_subnets_ids
  }

  cloudwatch_log_group_name                            = "/ecs/my-app"
  cloudwatch_metric_alarm_name                         = "ecs-app-cpu-utilization"
  cloudwatch_alarm_actions                             = ["arn:aws:sns:eu-west-1:123456789012:my-alerts"]
  cloudwatch_metric_alarm_cpu_utilization_threshold    = 80
  cloudwatch_metric_alarm_memory_utilization_threshold = 80

  depends_on = [module.alb, module.vpc, module.aws_ecr_repository]
}
