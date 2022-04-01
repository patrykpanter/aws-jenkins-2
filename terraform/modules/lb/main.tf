resource "aws_lb" "lb" {
  name               = "${var.name_prefix}-lb"
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets

  # access_logs {
  #   bucket  = var.log_bucket
  #   prefix  = "${var.name_prefix}-lb"
  #   enabled = true
  # }

  tags = {
    Name = "${var.name_prefix}-lb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "tf-example-lb-tg"
  port     = var.public_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "lb_tg_att" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = var.tarrget_instance_id
  port             = var.private_port
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.public_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}