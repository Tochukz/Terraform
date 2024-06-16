output "cluster_name" {
  value = aws_ecs_cluster.simple_cluster.name
}

output "service_name" {
  value = aws_ecs_service.simple_service.name
}

output "service_id" {
  value = aws_ecs_service.simple_service.id
}

output "task_arn" {
  value = aws_ecs_task_definition.simple_task.arn
}
