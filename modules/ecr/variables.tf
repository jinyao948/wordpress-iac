variable "project" {
  description = "Project prefix used in naming/tagging (e.g., wpdemo)"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to ECR resources"
  type        = map(string)
  default     = {}
}

variable "repository_suffix" {
  description = "Suffix for the repository name"
  type        = string
  default     = "wordpress"
}

variable "max_images" {
  description = "Number of images to retain via lifecycle policy"
  type        = number
  default     = 10
}
