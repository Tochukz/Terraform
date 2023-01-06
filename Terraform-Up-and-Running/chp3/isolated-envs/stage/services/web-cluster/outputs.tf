output "elb_dns_name" {
  value = aws_elb.simple_loadbalancer.dns_name
}
