module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.vpc.name
  cidr = var.vpc.cidr_block

  azs             = var.vpc.azs
  private_subnets = var.vpc.private_subnets
  public_subnets  = var.vpc.public_subnets

  enable_ipv6          = var.vpc.enable_ipv6
  enable_nat_gateway   = var.vpc.enable_nat_gateway
  enable_vpn_gateway   = var.vpc.enable_vpn_gateway
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
  enable_dns_support   = var.vpc.enable_dns_support

  tags = var.tags
}