# VPC configuration
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true # Enables DNS name resolution within a VPC
  enable_dns_hostnames             = true # Automatic hostname assignment for EC2 instances

  tags = merge(var.tags, {
    Name = "vpc"
  })
}

# VPC Flow Logs
resource "aws_flow_log" "vpc" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  log_destination = var.log_bucket
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "igw"
  })
}

# Public Subnets
locals {
  public_subnets_ipv6_cidrs = [
    cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 0),
    cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1)
  ]
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets_cidrs[count.index]
  ipv6_cidr_block   = local.public_subnets_ipv6_cidrs[count.index]
  availability_zone = var.azs[count.index] # Physical location of the subnet
  # map_public_ip_on_launch = true         # Automatically assigns a public IP to instances running in this subnet

  tags = merge(var.tags, {
    Name = "public-${substr(var.azs[count.index], -1, 1)}"
    Tier = "Public"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.azs[count.index] # Physical location of the subnet

  tags = merge(var.tags, {
    Name = "private-${substr(var.azs[count.index], -1, 1)}"
    Tier = "Private"
  })
}

# NAT Instance
resource "aws_instance" "nat" {
  ami                         = "ami-0274f4b62b6ae3bd5" # Amazon Linux 2023 AMI eu-north-1
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  source_dest_check           = false
  ebs_optimized               = true

  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  vpc_security_group_ids = [aws_security_group.nat_security_group.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install iptables-services -y
              sudo systemctl enable iptables
              sudo systemctl start iptables
              sudo sysctl -w net.ipv4.ip_forward=1
              sudo sysctl -p /etc/sysctl.d/custom-ip.conf
              sudo /sbin/iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
              sudo /sbin/iptables -F FORWARD
              sudo service iptables save
              EOF

  tags = merge(var.tags, {
    Name = "nat-instance"
  })
}

resource "aws_security_group" "nat_security_group" {
  name        = "nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "NAT ingress from private subnets services"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = concat(aws_subnet.private[*].cidr_block, [aws_subnet.public[1].cidr_block])
    security_groups = var.nat_instance_ingress_security_groups
  }

  egress {
    description = "NAT egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-sg"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route { # Internet Gateway IPv4 routing
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  route { # Internet Gateway IPv6 routing
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "public-rt"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "private-rt"
  })
}

# NAT Instance routing
resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

# Route Tables Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.private.id]

  tags = merge(var.tags, {
    Name = "s3-endpoint"
  })

  depends_on = [aws_route_table.private]
}