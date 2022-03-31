terraform {
  required_version = "~> 1.1.6"
}

resource "aws_vpc" "main" {
    cidr_block = var.cidr
    tags = {
      Name = "vpc-${var.vpc_name_prefix}"
    }
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name_prefix}-igw"
  }
}

resource "aws_route_table" "vpc_igw_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

	tags = {
    Name = "${var.vpc_name_prefix}-igw-rt"
  }
}

resource "aws_subnet" "subnet" {

  for_each = var.subnets_map
 
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr
	map_public_ip_on_launch = each.value.is_public
  availability_zone = each.value.az

  tags = {
    Name = "${var.vpc_name_prefix}-${each.value.name_prefix}-subnet"
  }
}

locals {
  public_subnets_map = {for k, v in var.subnets_map: k => v if v.is_public == true}
}

resource "aws_route_table_association" "igw_rt_association" {
  for_each = local.public_subnets_map
  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.vpc_igw_rt.id
}

# Resources below used only when at least one "has_nat" parameter defined as "true"

locals { 
  subnets_with_nat_map = {for k, v in var.subnets_map: k => v if v.has_nat == true}
}

resource "aws_eip" "nat-eip" {
  for_each = local.subnets_with_nat_map

	vpc = true
	tags = {
		Name = "${var.vpc_name_prefix}-${each.value.name_prefix}-nat-eip"
	}
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = local.subnets_with_nat_map
  
  allocation_id = aws_eip.nat-eip[each.key].id
  subnet_id     = aws_subnet.subnet[each.key].id

  tags = {
    Name = "${var.vpc_name_prefix}-${each.value.name_prefix}-nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.vpc_igw]
}

locals {
  subnets_using_nat = {for k, v in var.subnets_map: k => v if v.is_using_nat == true}
}

resource "aws_route_table" "private_rt" {
  for_each = local.subnets_using_nat
  
  vpc_id = aws_vpc.main.id
	
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[each.value.nat_gw].id
  }

	tags = {
    Name = "${var.vpc_name_prefix}-${each.value.name_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  for_each = local.subnets_using_nat

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = aws_route_table.private_rt[each.key].id
}