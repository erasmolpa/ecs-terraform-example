variable "tags" {
  type  = map(any)
  default = {
    Environment = "dev"
    Component   = "rds"
  }
}

