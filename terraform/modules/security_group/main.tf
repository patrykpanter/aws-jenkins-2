terraform {
  required_version = ">= 1.1.6"
}

resource "aws_security_group" "security_group" {
  for_each = var.security_groups
  
  name        = "${each.value.name_prefix}-sg"
#   description = "Bastion Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "${each.key}"
    from_port        = each.value.ingress_port
    to_port          = each.value.ingress_port
    protocol         = "tcp"
    cidr_blocks      = [each.value.ingress_cidr_blocks]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${each.value.name_prefix}-sg"
  }
}