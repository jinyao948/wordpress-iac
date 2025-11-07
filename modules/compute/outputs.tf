output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.this.id
}

output "launch_template_version" {
  description = "Launch template latest version"
  value       = aws_launch_template.this.latest_version
}
