output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}
output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}
output "private_subnet_id1" {
  value = aws_subnet.private_subnet1.id
}
output "private_subnet_id2" {
  value = aws_subnet.private_subnet2.id
}
output "web_sg_id" {
  value = aws_security_group.web_security_group.id
}
output "db_sg_id" {
  value = aws_security_group.db_security_group.id
}
output "network_interface_id" {
  value = aws_network_interface.custom_network_interface.id
}

