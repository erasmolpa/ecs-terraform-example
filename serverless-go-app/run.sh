docker build -t serverless-go-app .

##docker run -p 80:80 serverless-go-app

## REF https://earthly.dev/blog/deploy-dockcontainers-to-awsecs-using-terraform/
##aws-profile="erasmo-sre-admin"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 510330021658.dkr.ecr.us-east-1.amazonaws.com

docker tag serverless-go-app:latest 510330021658.dkr.ecr.us-east-1.amazonaws.com/serverless-go-app:latest

docker push 510330021658.dkr.ecr.us-east-1.amazonaws.com/serverless-go-app:latest