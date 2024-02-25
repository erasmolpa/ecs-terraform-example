data "aws_rds_engine_version" "engine_version" {
  engine = var.rds_engine
}

resource "aws_db_instance" "golang_serverless_db" {
  allocated_storage    = var.rds_storage
  db_name              = var.rds_db_name
  engine               = var.rds_engine
  engine_version       = data.aws_rds_engine_version.engine_version.version_actual
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  skip_final_snapshot  = var.skip_final_snapshot
  db_subnet_group_name  = var.subnet_group_name 
}