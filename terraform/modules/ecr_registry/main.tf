
resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  for_each   = { for idx, policy in var.lifecycle_policy_rules : idx => policy }
  policy = jsonencode({
    "rules" = [{
      "rulePriority" = each.value.rulePriority
      "description"  = each.value.description
      "selection" = {
        "tagStatus"   = each.value.selection.tagStatus
        "countType"   = each.value.selection.countType
        "countNumber" = each.value.selection.countNumber
        "countUnit" = each.value.selection.countUnit
        
      }
      "action" = {
        "type" = each.value.action.type
      }
    }]
  })
}

/**https://earthly.dev/blog/deploy-dockcontainers-to-awsecs-using-terraform/
resource "null_resource" "docker_packaging" {

  provisioner "local-exec" {
    command = <<EOF
	    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com
	    docker build -t "${aws_ecr_repository.ecr_repository.repository_url}:latest" -f ../serverless-go-app/Dockerfile .
	    docker push "${aws_ecr_repository.ecr_repository.repository_url}:latest"
	    EOF
  }


  triggers = {
    "run_at" = timestamp()
  }


  depends_on = [
    aws_ecr_repository.ecr_repository,
  ]
}

**/
