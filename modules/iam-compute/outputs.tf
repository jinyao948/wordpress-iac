output "instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances"
  value       = aws_iam_instance_profile.this.name
}

output "role_arn" {
  description = "IAM role ARN attached to EC2 instances"
  value       = aws_iam_role.this.arn
}
