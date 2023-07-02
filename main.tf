provider "aws" {
  profile = var.profile
  region  = var.region
}

module "vpc" {
  source = "./vpc_module"
}
