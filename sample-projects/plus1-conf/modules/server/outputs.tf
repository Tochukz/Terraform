output "public_ip" {
  # value = aws_eip_association.instance_eip_assoc.public_ip
  value = aws_instance.server_instance.public_ip
}
output "instance_id" {
  value = aws_instance.server_instance.id
}