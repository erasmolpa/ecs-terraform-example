variable "backend" {
  type = object({
    bucket_name              = string
    region                   = string
    dynamodb_table           = string
    bucket_sse_algorithm     = optional(string, "AES256")
    versioning_configuration = optional(string, "Enabled")
  })
}