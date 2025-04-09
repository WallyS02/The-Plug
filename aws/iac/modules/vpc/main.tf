# Main configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true # Enables DNS name resolution within a VPC
  enable_dns_hostnames = true # Automatic hostname assignment for EC2 instances

  tags = merge(var.tags, {
    Name = "${var.environment}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets_cidrs[count.index]
  availability_zone = var.azs[count.index] # Physical location of the subnet
  # map_public_ip_on_launch = true                 # Automatically assigns a public IP to instances running in this subnet

  tags = merge(var.tags, {
    Name = "${var.environment}-public-${substr(var.azs[count.index], -1, 1)}"
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
    Name = "${var.environment}-private-${substr(var.azs[count.index], -1, 1)}"
    Tier = "Private"
  })
}

# NAT Instance
resource "aws_instance" "nat" {
  ami                         = "ami-0274f4b62b6ae3bd5" # Amazon Linux 2023 AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  source_dest_check           = false

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

  tags = {
    Name = "${var.environment}-nat-instance"
  }
}

resource "aws_security_group" "nat_security_group" {
  name        = "nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = aws_subnet.private.*.cidr_block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-nat-sg"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route { # Internet Gateway routing
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-public-rt"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-private-rt"
  })
}

# NAT Instance routing
resource "aws_route" "nat_route" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = aws_instance.nat.primary_network_interface_id
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