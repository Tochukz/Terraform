output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}
output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}
output "web_sg_id" {
  value = aws_security_group.web_security_group.id
}
output "network_attach_id" {
  value = aws_network_interface.custom_network_interface.id
}