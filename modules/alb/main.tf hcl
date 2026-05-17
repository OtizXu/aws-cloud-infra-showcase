resource "aws_lb" "alb" {
  name = "${var.name_prefix}-alb-${var.environment}"
  load_balancer_type = "application"
  security_groups = var.security_groups
  subnets = var.public_subnet_ids
}

resource "aws_lb_target_group" "tg" {
  name = "${var.name_prefix}-tg-${var.environment}"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
