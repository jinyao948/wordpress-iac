// Security groups for ALB, WordPress EC2 instances, and RDS.

resource "aws_security_group" "alb" {
  name                   = "${var.project}-${var.env}-alb-sg"
  description            = "Allow HTTP ingress from the internet to the ALB"
  vpc_id                 = aws_vpc.this.id
  revoke_rules_on_delete = true

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "HTTPS from anywhere"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-alb-sg"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_security_group" "ec2" {
  name                   = "${var.project}-${var.env}-ec2-sg"
  description            = "Allow traffic from the ALB to WordPress EC2 instances"
  vpc_id                 = aws_vpc.this.id
  revoke_rules_on_delete = true

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-ec2-sg"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_security_group" "rds" {
  name                   = "${var.project}-${var.env}-rds-sg"
  description            = "Allow MySQL from WordPress EC2 instances"
  vpc_id                 = aws_vpc.this.id
  revoke_rules_on_delete = true

  ingress {
    description     = "MySQL from WordPress EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-rds-sg"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}
