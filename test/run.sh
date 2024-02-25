go mod init ecs-terraform-challenge

go mod tidy

terraform init ./terraform

go test backed_test.go

go test ecr_test.go

