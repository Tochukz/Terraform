output "db_host" {
  value = aws_db_instance.database_instance.endpoint
}
output "port" {
  value = aws_db_instance.database_instance.port
}
output "db_name" {
  value = aws_db_instance.database_instance.db_name
}
output "username" {
  value = aws_db_instance.database_instance.username
}
output "multi_az" {
  value = aws_db_instance.database_instance.multi_az
}
