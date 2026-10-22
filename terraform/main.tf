locals {
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "dev-demo-vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags                    = local.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = local.tags
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name_prefix = "dev-demo-web-"
  description = "HTTP only; no SSH"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "Public demo HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Outbound for DNS and Ubuntu package installation"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  credit_specification {
    cpu_credits = "standard"
  }
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<-SCRIPT
    #!/bin/bash
    set -eu
    export DEBIAN_FRONTEND=noninteractive
    apt-get -o Acquire::Retries=3 update
    apt-get -o Acquire::Retries=3 install -y nginx
    cat > /var/www/html/index.html <<'HTML'
    <!doctype html><html lang="en"><meta charset="utf-8"><title>Terraform demo</title>
    <h1>Hello from Terraform + Nginx!</h1><p>Ubuntu 22.04 · Singapore · Development</p></html>
    HTML
    systemctl enable --now nginx
  SCRIPT

  # Explicit instance tags are sent with RunInstances, not just added later.
  tags       = merge(local.tags, { Name = "dev-demo-nginx" })
  depends_on = [aws_route_table_association.public]
}

# Keep AWS private defaults; no ACL, public policy or public-access-block writes.


resource "aws_s3_bucket" "assets" {
  bucket        = var.bucket_name
  force_destroy = false
  tags          = local.tags
}

resource "aws_s3_object" "demo" {
  bucket       = aws_s3_bucket.assets.id
  key          = "assets/demo.svg"
  content_type = "image/svg+xml"
  content      = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"240\" height=\"60\"><rect width=\"240\" height=\"60\" fill=\"#172554\"/><text x=\"16\" y=\"38\" fill=\"white\" font-size=\"24\">Terraform demo</text></svg>"
}


