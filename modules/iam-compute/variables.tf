variable "project" {
  description = "Project prefix used in naming/tagging (e.g., wpdemo)"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}

variable "ssm_param_prefix" {
  description = "Prefix for SSM parameters instances may read"
  type        = string
}
