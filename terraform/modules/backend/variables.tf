variable "backend" {
  type = object({
    bucket_name          = string
    region               = string
    dynamodb_table       = string
    bucket_sse_algorithm = string
    versioning_configuration = optional(string, "Enabled")
  })
}