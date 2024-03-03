# 1 Create remote state
# 2 Create container registry
# 3 Build and publish app

# Separate Cluster Creation https://blog.knoldus.com/how-to-use-data-source-in-terraform/
# Golang connect to RDS https://docs.aws.amazon.com/code-library/latest/ug/go_2_rds_code_examples.html
# Localstack https://docs.localstack.cloud/user-guide/aws/rds/  

module "backend" {
  source  = "../terraform/modules/backend"
  backend = var.backend
}

module "aws_ecr_repository" {
  source                 = "../terraform/modules/ecr_registry"
  repository_name        = var.aws_ecr_repository
  lifecycle_policy_rules = var.aws_ecr_repository_lifecycle_policy_rules
}
