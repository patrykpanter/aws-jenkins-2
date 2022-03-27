resource "aws_vpc" "main" {
    cidr_block = var.cidr
}

resource "aws_route_table" "vpc_rt" {
  vpc_id = aws_vpc.main.id
	
	tags = {
    Name = "vpc-rt"
  }
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-igw"
  }
}

# Bastion subnet
resource "aws_route_table" "jenkins_bastion_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
	
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
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