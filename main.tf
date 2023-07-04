
module "backend"{
  source = "./modules/backend"
  backend = {
    bucket_name    = "backend"
    key            = "state/resource.tfstate"
    region         = "us-east-1"
    dynamodb_table = "resource-backend-lock"
  }
}

module "vpc" {
  source = "./modules/vpc"
}

module "fargate-cluster" {
  source = "./modules/ecs_cluster"
}