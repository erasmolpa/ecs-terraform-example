variable "rds_storage" {
  type        = number
  description = "Size of the RDS database in GB"
}
variable "rds_db_name" {
  type        = string
  description = "Name of the RDS database name"
}

variable "rds_engine" {
  type        = string
  description = "description"
  validation {
    condition = contains(["postgres", "mysql", "aurora-postgresql","aurora-mysql"], var.rds_engine)
    error_message = "The following rds_engine are allowed:  postgres,mysql,aurora-postgresql, aurora-mysql"
  }
}

variable "instance_class" {
    type = string
    validation {
      condition = contains(["db.t3.micro", "db.t2.micro"], var.instance_class)
      error_message = "value"
    }
}

variable "username" {
    type = string
    description = "name of the database username"
}

variable "password" {
    type = string
    description = "password of the database username"
}
    
variable "skip_final_snapshot" {
    type = bool
    default = true
    description = "skip_final_snapshot"
}

variable "subnet_group_name" {
  type = string
  default = ""
  description = "(Optional) Name of the subnet group"
}
