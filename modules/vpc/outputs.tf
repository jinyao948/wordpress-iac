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

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for key in sort(keys(aws_subnet.public)) : aws_subnet.public[key].id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for key in sort(keys(aws_subnet.private)) : aws_subnet.private[key].id]
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}
