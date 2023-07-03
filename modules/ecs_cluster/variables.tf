variable "name" {
  type    = string
  default = "fargate-cluster"
}

variable "tags" {
  type = map(any)
  default = {
    Environment = "dev"
    Component   = "ecs-cluster"
  }
}