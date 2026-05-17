data "aws_secretsmanager_secret_version" "rds_master" {
  count     = var.rds_master_secret_arn == "" ? 0 : 1
  secret_id = var.rds_master_secret_arn
}

locals {
  _rds_secret = var.rds_master_secret_arn == "" ? {} : jsondecode(data.aws_secretsmanager_secret_version.rds_master[0].secret_string)
  master_username = lookup(local._rds_secret, "username", var.rds_master_username)
  master_password = lookup(local._rds_secret, "password", var.rds_master_password)
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.name_prefix}-aurora-${var.environment}"
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version
  master_username    = local.master_username
  
  # Either use provided password or let AWS manage it
  master_password             = local.master_password != "" ? local.master_password : null
  manage_master_user_password = local.master_password == ""
  
  backup_retention_period = 7
  skip_final_snapshot = true
  vpc_security_group_ids = var.rds_security_group_id == "" ? [] : [var.rds_security_group_id]
}
