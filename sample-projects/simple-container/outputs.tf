output "cluster_name" {
  value = aws_ecs_cluster.simple_cluster.name
}

output "service_name" {
  value = aws_ecs_service.simple_service.name
}

output "service_id" {
  value = aws_ecs_service.simple_service.id
}

