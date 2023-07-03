/**
module "backend"{
  source = "./modules/backend"
}
**/

module "vpc" {
  source = "./modules/vpc"
}

module "fargate-cluster" {
  source = "./modules/ecs_cluster"
}