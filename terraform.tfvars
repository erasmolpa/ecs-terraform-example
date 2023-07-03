backend = {
  bucket_name     = "incode-challenge-backend"
  key             = "state/incode-challenge.tfstate"
  region          = "us-east-1"
  dynamodb_table  = "incode-challenge-backend-lock"
}
// SEE https://hands-on.cloud/aws-fargate-private-vpc-terraform-example/#h-vpc-deployment
vpc = {
  name          = "ecs-vpc"
  cidr_block     = "10.0.0.0/16"
  azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_ipv6             = false
  enable_nat_gateway      = true
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
  enable_vpn_gateway      = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
}

tags = {
  Environment = "dev"
  Project     = "incode-challenge"
  Component   = "vpc"
}