# Importar el módulo de ALB
module "my_alb" {
  source = "../../modules/alb"

  aws_security_group_http = {
    name        = "http_sg"
    description = "Security group for HTTP traffic"
    vpc_id      = "vpc-12345678"
  }

  aws_security_group_egress_all = {
    name        = "egress_all_sg"
    description = "Security group with all egress traffic allowed"
    vpc_id      = "vpc-12345678"
  }

  alb = {
    name               = "my-alb"
    internal           = false
    load_balancer_type = "application"
    subnets            = ["subnet-12345678", "subnet-87654321"]
  }
}
output "output_alb_arn" {
  value = module.my_alb.aws_alb_arn
}

output "output_alb_sg_egress_all_id" {
  value = module.my_alb.aws_sg_egress_all_id
}

output "output_alb_url" {
  value = module.my_alb.alb_url
}
