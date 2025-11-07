output "db_parameter_names" {
  description = "SSM parameter names for database configuration"
  value = {
    name     = aws_ssm_parameter.db_name.name
    username = aws_ssm_parameter.db_username.name
    password = aws_ssm_parameter.db_password.name
  }
}

output "db_parameter_arns" {
  description = "SSM parameter ARNs for database configuration"
  value = {
    name     = aws_ssm_parameter.db_name.arn
    username = aws_ssm_parameter.db_username.arn
    password = aws_ssm_parameter.db_password.arn
  }
}

output "wp_salt_parameter_names" {
  description = "SSM parameter names containing WordPress salts"
  value = {
    for key, param in aws_ssm_parameter.wp_salt :
    key => param.name
  }
}

output "wp_salt_parameter_arns" {
  description = "SSM parameter ARNs containing WordPress salts"
  value = {
    for key, param in aws_ssm_parameter.wp_salt :
    key => param.arn
  }
}

output "wp_setting_parameter_names" {
  description = "SSM parameter names for WordPress settings placeholders"
  value = {
    s3_bucket = aws_ssm_parameter.wp_s3_bucket_name.name
    site_url  = aws_ssm_parameter.wp_site_url.name
    home_url  = aws_ssm_parameter.wp_home_url.name
  }
}

output "bootstrap_admin_parameter_names" {
  description = "SSM parameter names for bootstrap admin credentials"
  value = {
    admin_user     = try(aws_ssm_parameter.bootstrap_admin_username[0].name, null)
    admin_password = try(aws_ssm_parameter.bootstrap_admin_password[0].name, null)
  }
}

output "db_password_parameter_name" {
  description = "Convenience output for the DB password parameter name"
  value       = aws_ssm_parameter.db_password.name
}
