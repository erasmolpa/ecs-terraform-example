variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "aws_repository_workshop"
}

variable "image_tag_mutability" {
  description = "The mutability setting for the repository image tags"
  type        = string
  default     = "IMMUTABLE"
}

variable "lifecycle_policy_rules" {
  description = "List of lifecycle policy rules for the repository"
  type = list(object({
    rule_priority         = number
    description           = string
    tag_prefix_list       = list(string)
    count_type            = string
    count_number          = number
    action_type           = string
    action_type_parameter = string
  }))
  default = [
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
