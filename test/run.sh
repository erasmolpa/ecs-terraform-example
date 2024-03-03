go mod init ecs-terraform-challenge

go mod tidy

terraform init ./terraform

go test test/backed_test.go

go test test/ecr_test.go

go test test/alb_test.go
