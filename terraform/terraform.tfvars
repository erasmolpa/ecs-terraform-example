profile = "sre-admin"
region  = "us-east-1"

backend = {
  bucket_name    = "terraform-backend-state-incode-demo"
  key            = "state/resource.tfstate"
  region         = "us-east-1"
  dynamodb_table = "resource-backend-lock"
}

aws_ecr_repository = "repository-docker"

aws_ecr_repository_lifecycle_policy_rules = [
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

ecs_cluster = {
  name = "fargate-cluster"
}

alb = {
  name               = "alb-test"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
