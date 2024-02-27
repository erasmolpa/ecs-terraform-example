# 1 Create remote state
# 2 Create container registry
# 3 Build adn publish app
# ---------
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

# En el archivo main.tf

module "vpc" {
  source = "../terraform/modules/vpc"
  vpc = var.vpc
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

  alb = var.alb
}

## --------------------------------------------------------------------------- ##
module "ecs_cluster" {
  source = "../terraform/modules/ecs_cluster"
  name   = var.ecs_cluster["name"]
}

module "ecs_application" {
  source  = "../terraform/modules/ecs_application"
  vpc_id  = module.vpc.vpc_id
  alb_arn = module.alb.aws_alb_arn

  ecs_task_execution_role = var.ecs_application["ecs_task_execution_role"]
  ecs_autoscale_role     = var.ecs_application["ecs_autoscale_role"]
  ecs_task               = var.ecs_application["ecs_task"]
  ecs_service            = var.ecs_application["ecs_service"]
}
