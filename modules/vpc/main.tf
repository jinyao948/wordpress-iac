// VPC core with public/private subnets and routing constructs.
// DNS remains enabled and AZ metadata is surfaced for downstream modules.

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs :
    format("%02d", idx + 1) => {
      cidr = cidr
      az   = element(local.azs, idx)
    }
  }

  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs :
    format("%02d", idx + 1) => {
      cidr = cidr
      az   = element(local.azs, idx)
    }
  }
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

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-public-${each.key}"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
    Tier        = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-private-${each.key}"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
    Tier        = "private"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-igw"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
    Tier        = "public"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-public-rt"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
    Tier        = "public"
  })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-private-rt"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
    Tier        = "private"
  })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
