# Terraform config
terraform {
  required_version = "1.1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.7.0"
    }

  }

  backend "s3" {
    bucket = "terraform-ppanter"
    key    = "terraform_013.tfstate"
    region = "eu-central-1"
  }
}

# AWS provider config
provider "aws" {
  region = "eu-central-1"
}

# VPC
module "vpc" {
  source = "./modules/vpc"
  cidr = var.vpc.cidr

}

# resource "aws_vpc" "jenkins_vpc" {
#   cidr_block = var.vpc.cidr

#   tags = {
#     Name = "jenkins-vpc"
#   }
# }

# resource "aws_route_table" "jenkins_vpc_rt" {
#   vpc_id = aws_vpc.jenkins_vpc.id
	
# 	tags = {
#     Name = "jenkins-vpc-rt"
#   }
# }

# resource "aws_internet_gateway" "jenkins_igw" {
#   vpc_id = aws_vpc.jenkins_vpc.id

#   tags = {
#     Name = "jenkins-igw"
#   }
# }

# Bastion host
resource "aws_route_table" "jenkins_bastion_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
	
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

	tags = {
    Name = "jenkins-bastion-rt"
  }
}

resource "aws_route_table_association" "bastion_rt_association" {
  subnet_id      = aws_subnet.jenkins_bastion_subnet.id
  route_table_id = aws_route_table.jenkins_bastion_rt.id
}

resource "aws_subnet" "jenkins_bastion_subnet" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = var.vpc.subnets.bastion.cidr
	map_public_ip_on_launch = true
  availability_zone = "eu-central-1b"

  tags = {
    Name = "jenkins-bastion-subnet"
  }
}

resource "aws_security_group" "jenkins_bastion_sg" {
  name        = "jenkins-bastion-sg"
  description = "Bastion Security Group"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-bastion-sg"
  }
}

data "aws_ami" "bastion" {
  filter {
    name   = "name"
    values = ["packer-bastion-*"]
  }
  most_recent = true

  owners = ["699942661490"]
}

resource "aws_instance" "jenkins_bastion_ec2" {
  ami           = data.aws_ami.bastion.id
  instance_type = "t2.micro"
	subnet_id = aws_subnet.jenkins_bastion_subnet.id
	vpc_security_group_ids = [aws_security_group.jenkins_bastion_sg.id]
	key_name        = aws_key_pair.deployer.key_name
  availability_zone = "eu-central-1b"

  tags = {
    Name = "jenkins-bastion-ec2"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJzvAxVDYpP9JlVe3CTtf1rYdkmhHCdqolf/LFJ0kRO9FutFSnSiKJYumy5bZXeP5fNE6zrt2JSm7DJn/hyaRmxQyuCPqTJs4czo20whXLkmA6W/1xfZH6T62aPea4+eLRUw8Vk+2OZ2hyOzxiItCOyZMkA5rvdiOGcHq7TLKA0s4nHbuNMR+zC1Fwl8ECoG9PeuAdaDGH3OOMWtQ+CbxZrHEGtWXuA2XNrlxanfLplaWEuiL5aKAGyDPcRJ0ub5qezPfm37/tJM3V5dKw4xtZjR8QsdMVXFUpVCrHeYo8fV1E5WpMrfWf5M6AeMcfyY9pzKlaS4uzhMsbtQrxf7dJbov3HsNhYvRhM+gAYXTv+hDMIsbCuCnhJLGS0zIyyk7muUzgy+jL+Ij/U0WLb3mSClpgk0uX7ekK7boHmJlZmHskvlW9gvbKw1vz20B5zmhE0PNtjgMbdKn8MkbVSErXKPczBVQ7zhM1Ll+2/DIlmloKUXaPyTMVk6CJnG39H4c= ppanter@DESKTOP-5OOPS6E"
}

# Jenkins master subnet
resource "aws_route_table" "jenkins_master_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
	
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

	tags = {
    Name = "jenkins-master-rt"
  }
}

resource "aws_route_table_association" "jenkins_master_rt_association" {
  subnet_id      = aws_subnet.jenkins_master_subnet.id
  route_table_id = aws_route_table.jenkins_master_rt.id
}

resource "aws_subnet" "jenkins_master_subnet" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = var.vpc.subnets.jenkins_master.cidr
	map_public_ip_on_launch = true
  availability_zone = "eu-central-1b"

  tags = {
    Name = "jenkins-master-subnet"
  }
}

resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins_master-sg"
  description = "Jenkins Master Security Group"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "${aws_instance.jenkins_bastion_ec2.private_ip}/32" ]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-master-sg"
  }
}

data "aws_ami" "jenkins_master" {
  filter {
    name   = "name"
    values = ["packer-jenkins-master-*"]
  }
  most_recent = true

  owners = ["699942661490"]
}

resource "aws_instance" "jenkins_master_ec2" {
  ami           = data.aws_ami.jenkins_master.id
  instance_type = "t2.micro"
	subnet_id = aws_subnet.jenkins_master_subnet.id
	vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
	key_name        = aws_key_pair.deployer.key_name
  availability_zone = "eu-central-1b"
  user_data_replace_on_change = true

  user_data = <<EOF
#!/bin/bash
sudo /etc/init.d/jenkins stop
sudo sed -i 's=<host>.*</host>=<host>${aws_instance.jenkins_node_ec2.private_ip}</host>=g' /var/lib/jenkins/nodes/remote-node/config.xml
sudo /etc/init.d/jenkins start
EOF

  tags = {
    Name = "jenkins-master-ec2"
  }
}

# resource "aws_nat_gateway" "jenkins_master_nat_gw" {
#   allocation_id = aws_eip.jenkins-nat-eip.id
#   subnet_id     = aws_subnet.jenkins_master_subnet.id

#   tags = {
#     Name = "jenkins-master-nat-gw"
#   }

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.jenkins_igw]
# }

# resource "aws_eip" "jenkins-nat-eip" {
# 	vpc = true
# 	tags = {
# 		Name = "jenkins-nat-eip"
# 	}
# }

resource "aws_volume_attachment" "jenkins_master_ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = "vol-090d8ed13914dd4bf"
  instance_id = aws_instance.jenkins_master_ec2.id
  stop_instance_before_detaching = true
}

# Jenkins node subnet
resource "aws_route_table" "jenkins_node_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
	
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_nat_gateway.jenkins_master_nat_gw.id
  # }

	tags = {
    Name = "jenkins-node-rt"
  }
}

resource "aws_route_table_association" "jenkins_node_rt_association" {
  subnet_id      = aws_subnet.jenkins_node_subnet.id
  route_table_id = aws_route_table.jenkins_node_rt.id
}

resource "aws_subnet" "jenkins_node_subnet" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = var.vpc.subnets.jenkins_node.cidr
  availability_zone = "eu-central-1b"

  tags = {
    Name = "jenkins-node-subnet"
  }
}

resource "aws_security_group" "jenkins_node_sg" {
  name        = "jenkins-node-sg"
  description = "Jenkins Node Security Group"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [ "${aws_instance.jenkins_bastion_ec2.private_ip}/32" ]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    #cidr_blocks      = [ "${aws_instance.jenkins_master_ec2.private_ip}/32" ]
    cidr_blocks      = [ "${var.vpc.subnets.jenkins_master.cidr}" ] # edited because of cycle error!
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-node-sg"
  }
}

data "aws_ami" "jenkins-node" {
  filter {
    name   = "name"
    values = ["packer-jenkins-node-*"]
  }
  most_recent = true

  owners = ["699942661490"]
}

resource "aws_instance" "jenkins_node_ec2" {
  ami           = data.aws_ami.jenkins-node.id
  instance_type = "t2.micro"
	subnet_id = aws_subnet.jenkins_node_subnet.id
	vpc_security_group_ids = [aws_security_group.jenkins_node_sg.id]
	key_name        = aws_key_pair.deployer.key_name
  availability_zone = "eu-central-1b"

  tags = {
    Name = "jenkins-node-ec2"
  }
}