provider "aws" {
  profile = var.profile
  region  = var.region
}
locals {
  version_terraform    = "=1.5.2"
  version_provider_aws = "=4.15.1"
}
