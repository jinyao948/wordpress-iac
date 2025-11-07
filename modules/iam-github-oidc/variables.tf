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

variable "github_repository" {
  description = "GitHub repository in the form owner/name"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository CI/CD will push to"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Auto Scaling Group name to refresh after deployments"
  type        = string
}

variable "region" {
  description = "AWS region for resource ARNs"
  type        = string
}
