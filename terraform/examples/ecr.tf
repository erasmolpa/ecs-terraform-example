module "aws_ecr_repository" {
  source          = "../terraform/modules/ecr_registry"
  repository_name = "serverless-go-app"
  lifecycle_policy_rules = jsonencode([{
    rulePriority = 1
    description  = "keep last 10 images"
    action = {
      type = "expire"
    }
    selection = {
      tagStatus   = "any"
      countType   = "imageCountMoreThan"
      countNumber = 10
    }
  }])
}