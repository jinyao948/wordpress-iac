output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "region_name" {
  description = "Current AWS region name"
  value       = data.aws_region.current.name
}

output "availability_zone_names" {
  description = "Available AZ names in this region"
  value       = data.aws_availability_zones.available.names
}
