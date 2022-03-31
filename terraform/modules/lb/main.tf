resource "aws_lb" "lb" {
  name               = "${var.name_prefix}-lb"
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = true

  # access_logs {
  #   bucket  = var.log_bucket
  #   prefix  = "${var.name_prefix}-lb"
  #   enabled = true
  # }

  tags = {
    Name = "${var.name_prefix}-lb"
  }
}

# resource "aws_lb_target_group" "target_group" {
#   name     = "tf-example-lb-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = var.vpc_id
# }

# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.target_group.arn
#   target_id        = var.tarrget_instance_id
#   port             = 80
# }