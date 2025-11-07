locals {
  role_name    = "${var.project}-${var.env}-wp-ec2-role"
  profile_name = "${var.project}-${var.env}-wp-ec2-profile"
  policy_name  = "${var.project}-${var.env}-wp-ec2-policy"
  ssm_prefix   = trim(var.ssm_param_prefix, "/")
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "inline" {
  statement {
    sid = "SSMRead"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/${local.ssm_prefix}",
      "arn:aws:ssm:*:*:parameter/${local.ssm_prefix}/*"
    ]
  }

  statement {
    sid = "ECRPull"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  statement {
    sid = "LogsWrite"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(var.tags, {
    Name        = local.role_name
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_iam_role_policy" "this" {
  name   = local.policy_name
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.inline.json
}

resource "aws_iam_instance_profile" "this" {
  name = local.profile_name
  role = aws_iam_role.this.name
}
