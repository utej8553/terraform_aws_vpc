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
