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

output "nat_instance_ip" {
  description = "Public IP of NAT Instance"
  value       = aws_instance.nat.public_ip
}