output "alb_dns_name" {
  description = "The DNS name of the application Load Balancer"
  value       = aws_lb.ecs_alb.dns_name
}

output "api_gateway" {
  value = aws_apigatewayv2_api.ecs_api.api_endpoint
}