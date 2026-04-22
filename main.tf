terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}
provider "aws"{
  region = var.region
}
resource "aws_vpc" "main"{
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "custom-vpc"
  }
}
resource "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.main.id
}
resource "aws_subnet" "public"{
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}
resource "aws_subnet" "private"{
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "private-subnet"
  }
}
resource "aws_route_table" "public_rt"{
  vpc_id = aws_vpc.main.id
}
resource "aws_route" "internet_access" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "public_assoc" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "bastian_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "key" {
  key_name = "bastain-key"
  public_key = file(var.public_key_path)
}
resource "aws_instance" "bastain"{
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastian_sg.id]
  key_name = aws_key_pair.key.key_name
  tags = {
    Name = "bastain-host"
  }
}
