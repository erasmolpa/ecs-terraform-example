variable "backend" {
  type = object({
    bucket_name          = string
    key                  = string
    region               = string
    dynamodb_table       = string
    bucket_sse_algorithm = string
    prevent_destroy      = bool
    versioning_configuration = optional(string, "Enabled")
  })
}