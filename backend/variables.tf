variable "bucket_name" {
  description = "Nombre del bucket de S3 para el backend remoto"
  type        = string
}

variable "key" {
  description = "Nombre del archivo de estado en el bucket de S3"
  type        = string
}

variable "region" {
  description = "Región del bucket de S3"
  type        = string
}

variable "dynamodb_table" {
  description = "Nombre de la tabla de DynamoDB para el bloqueo de estado"
  type        = string
}