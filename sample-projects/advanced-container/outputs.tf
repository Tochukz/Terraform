output "repository_url" {
  value = aws_ecr_repository.simple_repo.repository_url
}
output "lb_dns_name" {
  value = aws_alb.app_load_balancer.dns_name
}
