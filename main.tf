provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

# VPC 생성
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet 생성
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "main-igw"
  }
}

# Internet Gateway를 VPC에 연결
resource "aws_internet_gateway_attachment" "igw_attachment" {
  vpc_id             = aws_vpc.main_vpc.id
  internet_gateway_id = aws_internet_gateway.igw.id
}

