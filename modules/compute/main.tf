data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_caller_identity" "current" {}

locals {
  user_data = templatefile("${path.module}/templates/user_data.sh.tmpl", {
    region          = var.region
    param_prefix    = var.ssm_param_prefix
    wordpress_image = var.wordpress_image
    db_endpoint     = var.db_endpoint
    data_dir        = var.data_dir
    account_id      = data.aws_caller_identity.current.account_id
  })
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project}-${var.env}-wp-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    security_groups             = [var.ec2_security_group_id]
    associate_public_ip_address = true
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name        = "${var.project}-${var.env}-wp"
      Project     = var.project
      Environment = var.env
      ManagedBy   = "terraform"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.tags, {
      Name        = "${var.project}-${var.env}-wp-volume"
      Project     = var.project
      Environment = var.env
      ManagedBy   = "terraform"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-wp-lt"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.project}-${var.env}-wp-asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = var.public_subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 180
  default_cooldown          = 120
  force_delete              = false

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.env}-wp"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Project     = var.project
      Environment = var.env
      ManagedBy   = "terraform"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                      = "${var.project}-${var.env}-wp-cpu-policy"
  autoscaling_group_name    = aws_autoscaling_group.this.name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = var.cpu_target_value
    disable_scale_in = false
  }
}
