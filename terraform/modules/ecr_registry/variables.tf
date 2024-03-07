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
  # type = list(object({
  #   rulePriority = number
  #   description  = string
  #   selection = object({
  #     tagStatus     = string
  #     tagPrefixList = optional(list(string), [""])
  #     countType     = string
  #     countUnit     = optional(string,"days")
  #     countNumber   = number
  #   })
  #   action = object({
  #     type = string
  #   })
  # }))
  description = "List of ECR lifecycle policies"
  default = [{
    action = {
      type = "expire"
    }
    description  = "example"
    rulePriority = 1
    selection = {
      countNumber   = 10
      tagStatus     = "untagged"
      countType     = "imageCountMoreThan"
    }
    }
  ]
}
