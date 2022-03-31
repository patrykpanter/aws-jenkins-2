resource "aws_lb" "lb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = [var.subnet_id]

  enable_deletion_protection = true

  access_logs {
    bucket  = "terraform-ppanter"
    prefix  = "jenkins-lb"
    enabled = true
  }

  tags = {
    Name = "jenkins-lb"
  }
}