output "vpc_id" {
  value = module.network.vpc_id
}
output "public_subnet_id" {
  value = module.network.public_subnet_id
}
output "private_subnet_id1" {
  value = module.network.private_subnet_id1
}
output "private_subnet_id2" {
  value = module.network.private_subnet_id2
}
output "web_sg_id" {
  value = module.network.web_sg_id
}
output "db_sg_id" {
  value = module.network.db_sg_id
}
output "network_interface_id" {
  value = module.network.network_interface_id
}