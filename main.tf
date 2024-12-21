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
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "unique-terraform-state-bucket-12345" # 고유한 이름

#   lifecycle {
#     prevent_destroy = true
#   }

#   tags = {
#     Name = "TerraformStateBucket"
#   }
#   force_destroy = true # 필요에 따라 사용, 기존 객체 강제 삭제 가능
# }

# # S3 버전 관리 설정
# resource "aws_s3_bucket_versioning" "versioning" {
#   bucket = aws_s3_bucket.terraform_state.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # S3 암호화 설정
# resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# S3 퍼블릭 액세스 차단
# resource "aws_s3_bucket_public_access_block" "block_public_access" {
#   bucket = aws_s3_bucket.terraform_state.id

#   block_public_acls   = true
#   block_public_policy = true
#   ignore_public_acls  = true
#   restrict_public_buckets = true
# }

# # DynamoDB 테이블 생성 (잠금 관리)
# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   lifecycle {
#     prevent_destroy = true
#   }
  
#   tags = {
#     Name = "TerraformLocks"
#   }
# }

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
  subnet_id = module.vpc.public_subnet_ids[0] # ap-northeast-2a 서브넷
  vpc_id          = module.vpc.vpc_id
  name            = "web-server"
}


# module "s3" {
#   source      = "./modules/s3"
#   bucket_name = "unique-terraform-state-bucket-12345"
# }


# EKS 클러스터 모듈 호출
module "eks" {
  source        = "./modules/eks"   # EKS 모듈을 호출
  cluster_name  = "my-cluster"
  subnet_ids    = module.vpc.public_subnet_ids  # VPC에서 퍼블릭 서브넷 ID 전달
}

# EKS 노드 그룹 설정
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = module.eks.eks_cluster_name  # EKS 클러스터 이름 참조
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.public_subnet_ids  # 퍼블릭 서브넷 ID들

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  depends_on = [
    module.eks.eks_cluster_name,
    aws_iam_role_policy_attachment.eks_node_policy
  ]
}

# EKS 노드 IAM 역할 (EC2 인스턴스가 EKS 클러스터와 상호작용할 수 있도록)
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# EKS 노드 정책 첨부
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}