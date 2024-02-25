module "aws_ecr_repository" {
  source          = "../terraform/modules/ecr_registry"
  repository_name = "repositoryexample"
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
