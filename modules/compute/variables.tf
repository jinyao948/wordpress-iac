variable "project" {
  description = "Project prefix used in naming/tagging (e.g., wpdemo)"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "public_subnet_ids" {
  description = "Public subnet IDs where EC2 instances run"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "Security group attached to WordPress instances"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN for registration"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for WordPress instances"
  type        = string
  default     = "t4g.micro"
}

variable "ssm_param_prefix" {
  description = "SSM parameter prefix (e.g., /wpdemo/dev)"
  type        = string
}

variable "region" {
  description = "AWS region for metadata in user data"
  type        = string
}

variable "wordpress_image" {
  description = "Container image for WordPress"
  type        = string
  default     = "wordpress:php8.2-apache"
}

variable "data_dir" {
  description = "Host directory to persist WordPress content"
  type        = string
  default     = "/var/www/html"
}

variable "db_endpoint" {
  description = "Database endpoint hostname"
  type        = string
}

variable "cpu_target_value" {
  description = "Target average CPU utilization for scaling"
  type        = number
  default     = 45
}
