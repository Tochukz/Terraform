output "vpc_id" {
  value = module.network.vpc_id
}
output "public_subnet_id" {
  value = module.network.public_subnet_id
}
output "web_sg_id" {
  value = module.network.web_sg_id
}
output "network_attach_id" {
  value = module.network.network_attach_id
}