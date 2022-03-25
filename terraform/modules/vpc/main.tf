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

# resource "aws_subnet" "main" {

# }