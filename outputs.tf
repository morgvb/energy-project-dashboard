output "route53_resolver_endpoint_id" {
  description = "ID of the Route 53 Resolver Endpoint"
  value       = aws_route53_resolver_endpoint.project-dns.id
}

output "aws_vpc_id" {
  description = "Production VPC Endpoint"
  value       = aws_vpc.prod-vpc.id
}

# Show database endpoints

output "project-db-endpoint" {
  description = "Endpoint of the project database"
  value       = aws_db_instance.project-db.endpoint
}

output "visualization-db-endpoint" {
  description = "Endpoint of the data visualization database"
  value       = aws_db_instance.visualization-db.endpoint
}