provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

# VPC 생성
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MainVPC"
  }
}

# 서브넷 생성
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a" # 서울 리전의 가용 영역
  tags = {
    Name = "MainSubnet"
  }
}

# EC2 인스턴스 생성
resource "aws_instance" "web_server" {
  ami           = "ami-049788618f07e189d" # Amazon Linux 2 AMI (서울 리전)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  tags = {
    Name = "WebServer"
  }
}

# S3 버킷 생성
resource "aws_s3_bucket" "terraform_state" {
  bucket = "unique-terraform-state-bucket-12345" # 고유한 이름

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "TerraformStateBucket"
  }
  force_destroy = true # 필요에 따라 사용, 기존 객체 강제 삭제 가능
}

# S3 버전 관리 설정
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

# DynamoDB 테이블 생성 (잠금 관리)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
  
  tags = {
    Name = "TerraformLocks"
  }
}

terraform {
  backend "s3" {
    bucket         = "unique-terraform-state-bucket-12345"
    key            = "terraform/state"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


module "vpc" {
  source              = "./modules/vpc"
  cidr_block          = "10.0.0.0/16"
  name                = "main-vpc"
  public_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  private_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
}

module "ec2" {
  source          = "./modules/ec2"
  ami             = "ami-049788618f07e189d" # ap-northeast-2에 유효한 AMI ID
  instance_type   = "t2.micro"
  subnet_id       = "subnet-0d2f243963179b8b4" # ap-northeast-2a 서브넷
  vpc_id          = module.vpc.vpc_id
  name            = "web-server"
}


module "s3" {
  source      = "./modules/s3"
  bucket_name = "unique-terraform-state-bucket-12345"
}
