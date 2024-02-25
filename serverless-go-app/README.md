# Deploy a Serverless Golang App to AWS Fargate

## Pre-Requirements
* Docker
* Golang
* AWS Account
* AWS CLI


## Step 1

Create a golang project with main.go file. Paste the below code.
```bash
package main

import "github.com/gofiber/fiber/v2"

func main() {
	serverless-go-app := fiber.New()

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	serverless-go-app.Listen(":80")
}
```

## Add fiber framework
```bash
go get github.com/gofiber/fiber/v2
```
## Step 2

Create a Dockerfile. Paste the below code.

```bash
FROM golang:1.16-alpine
WORKDIR /serverless-go-app
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN go build -o ./out/dist .
CMD ./out/dist
```

Run the below command on the terminal to generate out and dist.
```bash
go build -o ./out/dist .
```

## Step 3
Build Docker container.
```bash
docker build -t serverless-go-app .
```

Run Docker container.

```bash
docker run -p 8888:80 serverless-go-app
```
If you open http://127.0.0.1:8000 or http://localhost:8888 on your browser, you will see the output.

## Step 4
Let's push the project to the cloud. Open your AWS Management Console.

### Elastic Container Registery

* Create a repository with name of app either private or public. In my case, I choose public. We will push Docker container to this repository. 


After created repository, you will see Push commands for app.

* Retrieve an authentication token and authenticate your Docker client to your registry.
  Use the AWS CLI:
```bash
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/c0r3n4u9
```
Here, I got an error. (AWS ECR user is not authorized to perform: ecr-public:GetAuthorizationToken on resource:)
If you got same error, you can add permision. (AmazonElasticContainerRegistryPublicFullAccess)
Solution : https://stackoverflow.com/questions/65727113/aws-ecr-user-is-not-authorized-to-perform-ecr-publicgetauthorizationtoken-on-r
* (Because we already build docker container, you can skip this command.
  )
Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions here . You can skip this step if your image is already built:
```bash
docker build -t serverless-go-app .
```

* After the build completes, tag your image so you can push the image to this repository:

```bash 
docker tag app:latest public.ecr.aws/c0r3n4u9/app:latestdocker run -p 8888:80 app
```

* Run the following command to push this image to your newly created AWS repository:

```bash
docker push public.ecr.aws/c0r3n4u9/serverless-go-app:latest
```