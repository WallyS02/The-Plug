output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnets ID list"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnets ID list"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ips" {
  description = "Public IP of NAT Gateway"
  value       = aws_nat_gateway.main[*].public_ip
}

output "vpc_endpoint_s3_id" {
  description = "VPC Endpoint for S3 ID"
  value       = try(aws_vpc_endpoint.s3[0].id, "")
}