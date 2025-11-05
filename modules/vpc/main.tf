// VPC core (no subnets yet). DNS is enabled.
// We also expose region and AZs for downstream subnet placement.

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-vpc"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}
