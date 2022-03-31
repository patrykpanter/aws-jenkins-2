terraform {
  required_version = ">= 1.1.6"
}

data "aws_ami" "packer_ami" {
  for_each = var.ec2s_map

  filter {
    name   = "name"
    values = ["${each.value.packer_ami_prefix}"]
  }
  most_recent = true

  owners = ["${each.value.packer_ami_owner}"]
}

locals {
    security_group_ids_map_of_sets =    {for k1, v1 in var.ec2s_map: k1 =>
                                            flatten([for v2 in v1.security_groups: 
                                                [for k3, v3 in var.security_group_ids_map: v3 if k3 == v2]
                                            ])
                                        }
}

resource "aws_instance" "ec2" {
  for_each = var.ec2s_map

  ami           = data.aws_ami.packer_ami[each.key].id
  instance_type = each.value.instance_type
# key_name        = aws_key_pair.deployer.key_name
  availability_zone = each.value.availability_zone

  network_interface {
    network_interface_id = aws_network_interface.network_interface[each.key].id
    device_index = 0
  }

  tags = {
    Name = "${each.value.name_prefix}-ec2"
  }
}

resource "aws_network_interface" "network_interface" {
  for_each = var.ec2s_map

  subnet_id   = var.subnet_ids_map[each.value.subnet]
  private_ips = each.value.is_private_ip ? [each.value.private_ip] : []

  security_groups = local.security_group_ids_map_of_sets[each.key]
  
  tags = {
    Name = "${each.value.name_prefix}-ni"
  }
}

resource "aws_volume_attachment" "ebs" {
  device_name = "/dev/sdf"
  volume_id   = "vol-090d8ed13914dd4bf"
  instance_id = aws_instance.ec2[var.ebs_instance].id
  stop_instance_before_detaching = true
}
