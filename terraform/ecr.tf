module "ecr" {
  source = "../terraform/modules/ecr"

  repository_name = "serverless-go-app"
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