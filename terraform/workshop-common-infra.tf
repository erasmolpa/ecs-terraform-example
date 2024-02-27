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
  source = "../terraform/modules/backend"
  backend = {
    bucket_name    = "terraform-backend-state-incode-demo"
    key            = "state/resource.tfstate"
    region         = "us-east-1"
    dynamodb_table = "resource-backend-lock"
  }
}


module "aws_ecr_repository" {
  source          = "../terraform/modules/ecr_registry"
  repository_name = "repository_workshop_serverless_app"
  lifecycle_policy_rules = [
    {
      rule_priority         = 1
      description           = "keep last 10 images"
      tag_prefix_list       = []
      count_type            = "imageCountMoreThan"
      count_number          = 10
      action_type           = "expire"
      action_type_parameter = ""
    }
  ]
}
