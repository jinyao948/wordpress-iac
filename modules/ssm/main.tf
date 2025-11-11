locals {
  param_prefix = "/${var.project}/${var.env}"

  wp_salt_paths = [
    "wp/salt/auth",
    "wp/salt/secure_auth",
    "wp/salt/logged_in",
    "wp/salt/nonce",
    "wp/auth_salt",
    "wp/secure_auth_salt",
    "wp/logged_in_salt",
    "wp/nonce_salt"
  ]
}

resource "aws_ssm_parameter" "db_name" {
  name        = "${local.param_prefix}/db/name"
  type        = "String"
  value       = var.db_name
  description = "WordPress MySQL database name"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-db-name"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_ssm_parameter" "db_username" {
  name        = "${local.param_prefix}/db/username"
  type        = "String"
  value       = var.db_username
  description = "WordPress MySQL username"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-db-user"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_ssm_parameter" "db_password" {
  name        = "${local.param_prefix}/db/password"
  type        = "SecureString"
  value       = var.db_password
  description = "WordPress MySQL password (rotate via Parameter Store)"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-db-pass"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "random_password" "wp_salt" {
  for_each = toset(local.wp_salt_paths)

  length           = 64
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>:?/"
}

resource "aws_ssm_parameter" "wp_salt" {
  for_each = random_password.wp_salt

  name        = "${local.param_prefix}/${each.key}"
  type        = "SecureString"
  value       = each.value.result
  description = "WordPress salt ${each.key}"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-wp-${replace(each.key, "/", "-")}"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_ssm_parameter" "wp_s3_bucket_name" {
  name        = "${local.param_prefix}/wp/s3/bucket_name"
  type        = "String"
  value       = var.s3_bucket_name
  description = "WordPress media offload bucket name (set once bucket exists)"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-wp-s3-bucket"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_ssm_parameter" "wp_site_url" {
  name        = "${local.param_prefix}/wp/site_url"
  type        = "String"
  value       = var.site_url
  description = "WordPress site URL (update when ALB DNS is known)"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-wp-site-url"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_ssm_parameter" "wp_home_url" {
  name        = "${local.param_prefix}/wp/home_url"
  type        = "String"
  value       = var.home_url
  description = "WordPress home URL (update when ALB DNS is known)"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-wp-home-url"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "random_password" "bootstrap_admin_password" {
  count = var.create_bootstrap_admin_creds ? 1 : 0

  length           = var.admin_password_length
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "bootstrap_admin_username" {
  count = var.create_bootstrap_admin_creds ? 1 : 0

  name        = "${local.param_prefix}/wp/bootstrap/admin_user"
  type        = "SecureString"
  value       = var.admin_username
  description = "Bootstrap WordPress admin username (rotate/remove post-setup)"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-wp-admin-user"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_ssm_parameter" "bootstrap_admin_password" {
  count = var.create_bootstrap_admin_creds ? 1 : 0

  name        = "${local.param_prefix}/wp/bootstrap/admin_password"
  type        = "SecureString"
  value       = random_password.bootstrap_admin_password[count.index].result
  description = "Bootstrap WordPress admin password (rotate/remove post-setup)"

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-wp-admin-pass"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}
