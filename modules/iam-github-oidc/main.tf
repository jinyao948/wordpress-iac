locals {
  role_name     = "${var.project}-${var.env}-github-oidc"
  provider_url  = "https://token.actions.githubusercontent.com"
  provider_host = "token.actions.githubusercontent.com"
  sub_value     = "repo:${var.github_repository}:ref:refs/heads/main"
  asg_arn       = "arn:aws:autoscaling:${var.region}:%s:autoScalingGroup:*:autoScalingGroupName/${var.autoscaling_group_name}"
  thumbprint    = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url             = local.provider_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.thumbprint]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.provider_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.provider_host}:sub"
      values   = [local.sub_value]
    }
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

locals {
  account_id   = data.aws_caller_identity.current.account_id
  asg_arn_full = format(local.asg_arn, local.account_id)
}

data "aws_iam_policy_document" "ci_permissions" {
  statement {
    sid       = "ECRToken"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "ECRPushPull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]
    resources = [var.ecr_repository_arn]
  }

  statement {
    sid = "ASGRefresh"
    actions = [
      "autoscaling:StartInstanceRefresh",
      "autoscaling:DescribeAutoScalingGroups"
    ]
    resources = [local.asg_arn_full]
  }
}

resource "aws_iam_role_policy" "ci" {
  name   = "${local.role_name}-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.ci_permissions.json
}
