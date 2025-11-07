variable "project" {
  description = "Project prefix used in naming/tagging (e.g., wpdemo)"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used for the target group"
  type        = string
}

variable "stickiness_duration" {
  description = "Stickiness duration in seconds"
  type        = number
  default     = 900
}

variable "health_check_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/healthz.php"
}
