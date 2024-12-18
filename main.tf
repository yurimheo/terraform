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
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true # 인스턴스에 공인 IP 자동 할당

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
resource "aws_internet_gateway_attachment" "igw_attach" {
  vpc_id             = aws_vpc.main_vpc.id
  internet_gateway_id = aws_internet_gateway.igw.id
}

# 라우팅 테이블 생성 (Public Subnet용)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "public-route-table"
  }
}

# Internet Gateway를 통해 외부 트래픽 라우팅
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# 라우팅 테이블을 Public Subnet에 연결
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# 보안 그룹 생성
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow SSH and HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.main_vpc.id

  # 인바운드 규칙
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP 허용 (테스트용)
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 규칙 (모든 트래픽 허용)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

# EC2 키페어 생성 (로컬에 .pem 파일 저장)
resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("C:/Users/soldesk/.ssh/id_rsa.pub")
}

# EC2 인스턴스 생성
# 최신 Amazon Linux 2 AMI ID 가져오기
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"] # Amazon 공식 계정
}

# EC2 인스턴스 생성
resource "aws_instance" "public_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = aws_key_pair.my_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "public-ec2"
  }
}



