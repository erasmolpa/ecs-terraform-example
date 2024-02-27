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
module "backend" {
  source   = "../terraform/modules/backend"
  backend  = var.backend
}

module "aws_ecr_repository" {
  source          = "../terraform/modules/ecr_registry"
  repository_name = var.aws_ecr_repository["repository_name"]
  lifecycle_policy_rules = var.aws_ecr_repository["lifecycle_policy_rules"]
}
