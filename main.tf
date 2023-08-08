terraform {
    required_version = ">=1.5.4"
}

provider "aws" {
    region = var.availability_zone
    # In a real configuration, configure keys with Hashicorp Vault
    access_key = <INSERT_KEY>
    secret_key = <INSERT_SECRET_KEY>
}

# Create Route 53 Resolver

resource "aws_route53_resolver_endpoint" "project-dns" {
  name      = "project-dns"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.allow_web.id
  ]

  ip_address {
    subnet_id = aws_subnet.public-subnet-1.id
  }

  ip_address {
    subnet_id = aws_subnet.public-subnet-2.id
  }

  tags = {
    Environment = "Prod"
  }
}

# Create VPC

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
}

# Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

# Create Public Route Table

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public"
  }
}

# Create Private Route Table

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "private"
  }
}

# Create Public Subnets

resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = var.az1

    tags = {
        Name = "public subnet 1"
    }
}

resource "aws_subnet" "public-subnet-2" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = var.az2

    tags = {
        Name = "public subnet 2"
    }
}

resource "aws_subnet" "public-subnet-3" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = var.az1

    tags = {
        Name = "public subnet 3"
    }
}
# Create Private Subnets

resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = var.az2

    tags = {
        Name = "private subnet 1"
    }
}

resource "aws_subnet" "private-subnet-2" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = var.az1

    tags = {
        Name = "private subnet 2"
    }
}

resource "aws_subnet" "private-subnet-3" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.5.0/24"
    availability_zone = var.az2

    tags = {
        Name = "private subnet 3"
    }
}

# Assign subnet to route table

resource "aws_route_table_association" "public" {
  for_each = toset(var.public_subnet_ids)
  subnet_id = each.key
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private" {
  for_each = toset(var.private_subnet_ids)
  subnet_id = each.key
  route_table_id = aws_route_table.private-rt.id
}

# Create Security Group

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# Create Application Load Balancers

resource "aws_lb" "project-lb" {
  name               = "project-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb" "service-lb" {
  name               = "service-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

# Create ECS Tasks

data "aws_ecs_task_definition" "project-service" {
  task_definition = "${aws_ecs_task_definition.project-service.family}"
}

data "aws_ecs_task_definition" "data-service" {
  task_definition = "${aws_ecs_task_definition.data-service.family}"
}

resource "aws_ecs_task_set" "project-service" {
  service         = project_service.example.id
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "project_service:latest"
    container_port   = 8080
  }
}

resource "aws_ecs_task_set" "data-service" {
  service         = data_service.example.id
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "data_service:latest"
    container_port   = 8080
  }
}

# Create ECR repositories

resource "aws_ecr_repository" "project-service-ecr" {
  name = "project-service"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "Project Service"
  }
}

resource "aws_ecr_repository" "data-service-ecr" {
  name = "data-service"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    Name = "Data Visualization Service"
  }
}