locals {
  project     = "wpdemo"
  env         = "dev"
  tags        = {}
  db_name     = "wordpress"
  db_username = "wpuser"
}

resource "random_password" "db_master" {
  length           = 32
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>:?/"
}

module "secrets" {
  source = "../../modules/ssm"

  project     = local.project
  env         = local.env
  db_name     = local.db_name
  db_username = local.db_username
  db_password = random_password.db_master.result
  tags        = local.tags
}

module "rds_mysql" {
  source = "../../modules/rds-mysql"

  project = local.project
  env     = local.env
  tags    = local.tags

  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.vpc.rds_sg_id
  db_name               = local.db_name
  db_username           = local.db_username
  db_password           = random_password.db_master.result
}

output "database_summary" {
  value = {
    db_endpoint         = module.rds_mysql.db_endpoint
    db_port             = module.rds_mysql.db_port
    db_id               = module.rds_mysql.db_identifier
    ssm_db              = module.secrets.db_parameter_names
    ssm_salts           = module.secrets.wp_salt_parameter_names
    ssm_settings        = module.secrets.wp_setting_parameter_names
    ssm_bootstrap_admin = module.secrets.bootstrap_admin_parameter_names
  }
}
