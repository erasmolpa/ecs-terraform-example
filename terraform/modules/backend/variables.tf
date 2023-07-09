variable "backend" {
  type = object({
    bucket_name    = string
    key            = string
    region         = string
    dynamodb_table = string
  })
}