output "arn" {
  value = aws_instance.server_instance.arn
}
output "public_dns" {
  value = aws_instance.server_instance.public_dns
}
output "public_ip" {
  value = aws_instance.server_instance.public_ip
}