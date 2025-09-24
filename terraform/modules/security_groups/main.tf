locals {
  public_cidrs  = var.public_subnet_cidrs
  private_cidrs = var.private_subnet_cidrs
}

# Public Gateway SG
resource "aws_security_group" "public_gateway" {
  name        = "${var.project_name}-public-gateway"
  description = "Ingress 80/443 from Internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-public-gateway"
    Project = var.project_name
  }
}

# App Nodes SG
resource "aws_security_group" "app_nodes" {
  name        = "${var.project_name}-app-nodes"
  description = "EKS node group security"
  vpc_id      = var.vpc_id

  ingress {
    description = "K8s API 6443 from Private subnets"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = local.private_cidrs
  }

  ingress {
    description = "Overlay networking 8472 (VXLAN)"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = local.private_cidrs
  }

  ingress {
    description = "HTTP from Public subnets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.public_cidrs
  }

  ingress {
    description = "HTTPS from Public subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.public_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-nodes"
  }
}

# Monitoring SG
resource "aws_security_group" "monitoring" {
  name        = "${var.project_name}-monitoring"
  description = "Observability UIs and scraping"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [
      { port = 3000, name = "Grafana" },
      { port = 9090, name = "Prometheus" },
      { port = 3100, name = "Loki" },
      { port = 3200, name = "Tempo" },
      { port = 5665, name = "Icinga2" },
    ]
    content {
      description = ingress.value.name
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = local.public_cidrs
    }
  }

  ingress {
    description = "Scraping from Private subnets"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = local.private_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-monitoring"
  }
}

# Database SG
resource "aws_security_group" "db" {
  name        = "${var.project_name}-db"
  description = "Database access from private subnets"
  vpc_id      = var.vpc_id

  ingress {
    description = "MongoDB 27017"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = local.private_cidrs
  }

  ingress {
    description = "PostgreSQL 5432"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.private_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db"
  }
}
