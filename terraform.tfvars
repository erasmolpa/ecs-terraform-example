profile = "erasmo-sre-admin"

vpc = {
  name                 = "ecs-vpc"
  cidr_block           = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_ipv6          = false
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

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