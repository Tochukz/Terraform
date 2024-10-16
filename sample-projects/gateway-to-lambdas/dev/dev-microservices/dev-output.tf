output "api_gateway_endpoint" {
  value = module.microservices.api_gateway_endpoint
}
output "user_service_endpoint" {
  value = "${module.microservices.api_gateway_endpoint}/user"
}
output "catalog_service_endpoint" {
  value = "${module.microservices.api_gateway_endpoint}/product"
}