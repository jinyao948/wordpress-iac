resource "aws_lb" "this" {
  name               = "${var.project}-${var.env}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  idle_timeout                     = 60
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-alb"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project}-${var.env}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = var.stickiness_duration
    enabled         = true
  }

  deregistration_delay = 15

  tags = merge(var.tags, {
    Name        = "${var.project}-${var.env}-tg"
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.this.arn
      }

      stickiness {
        enabled  = true
        duration = var.stickiness_duration
      }
    }
  }
}
# resource "aws_lb_listener" "https" {
#   count             = 0
#   load_balancer_arn = aws_lb.this.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.acm_certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.this.arn
#   }
# }
