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
  subnet_id = var.subnet_ids_map[each.value.subnet]
  vpc_security_group_ids = local.security_group_ids_map_of_sets[each.key]
# key_name        = aws_key_pair.deployer.key_name
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${each.value.name_prefix}-ec2"
  }
}




# resource "aws_instance" "jenkins_master_ec2" {
#   ami           = data.aws_ami.jenkins_master.id
#   instance_type = "t2.micro"
# 	subnet_id = aws_subnet.jenkins_master_subnet.id
# 	vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
# 	key_name        = aws_key_pair.deployer.key_name
#   availability_zone = "eu-central-1b"
#   user_data_replace_on_change = true

#   user_data = <<EOF
# #!/bin/bash
# sudo /etc/init.d/jenkins stop
# sudo sed -i 's=<host>.*</host>=<host>${aws_instance.jenkins_node_ec2.private_ip}</host>=g' /var/lib/jenkins/nodes/remote-node/config.xml
# sudo /etc/init.d/jenkins start
# EOF

#   tags = {
#     Name = "jenkins-master-ec2"
#   }
# }

