locals {
  identifier = substr(regexreplace(lower("${var.project}-${var.env}-mysql"), "[^a-z0-9-]", "-"), 0, 63)
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.env}-mysql-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-mysql-subnets"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_db_instance" "this" {
  identifier = local.identifier

  engine         = "mysql"
  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage = var.allocated_storage_gb
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_security_group_id]

  multi_az            = false
  publicly_accessible = false
  storage_encrypted   = true

  backup_retention_period = var.backup_retention_days

  auto_minor_version_upgrade          = true
  delete_automated_backups            = true
  copy_tags_to_snapshot               = true
  skip_final_snapshot                 = true
  deletion_protection                 = false
  apply_immediately                   = true
  performance_insights_enabled        = false
  iam_database_authentication_enabled = false

  monitoring_interval = 0

  enabled_cloudwatch_logs_exports = ["error"]

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-mysql"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
    Tier        = "data"
  })
}
