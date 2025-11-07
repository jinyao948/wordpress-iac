variable "project" {
  description = "Project prefix used in naming/tagging (e.g., wpdemo)"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "db_name" {
  description = "Logical database name stored in SSM"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Database username stored in SSM"
  type        = string
  default     = "wpuser"
}

variable "db_password" {
  description = "Database password to store securely in SSM"
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "Optional bootstrap WordPress admin username (rotate/remove post-setup)"
  type        = string
  default     = "wpadmin"
}

variable "admin_password_length" {
  description = "Length of the generated bootstrap admin password"
  type        = number
  default     = 24
}

variable "create_bootstrap_admin_creds" {
  description = "Whether to create bootstrap admin credentials parameters"
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Placeholder S3 bucket name for media offload (updated later once bucket exists)"
  type        = string
  default     = ""
}

variable "site_url" {
  description = "Placeholder WordPress site URL (updated once ALB DNS is known)"
  type        = string
  default     = ""
}

variable "home_url" {
  description = "Placeholder WordPress home URL (updated once ALB DNS is known)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to parameters"
  type        = map(string)
  default     = {}
}
