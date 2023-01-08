output "elb_dns_name" {
  value = aws_elb.simple_loadbalancer.dns_name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.simple_autoscaling_group.name
}

output "web_security_group_id" {
  value = aws_security_group.web_security_group.id
}