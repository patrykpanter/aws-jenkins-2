output "vpc_id" {
    value = aws_vpc.main.id
}

output "subnet_ids" {
    value = {for i, v in aws_subnet.subnet: i => v.id}
}