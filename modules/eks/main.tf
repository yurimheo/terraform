# EKS 서비스 역할 (클러스터 관리 역할)
resource "aws_iam_role" "eks_service_role" {
  name = "eks-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# EKS 서비스 정책 첨부 (AmazonEKSClusterPolicy)
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS 노드 역할 (EC2 인스턴스가 EKS 클러스터와 상호작용할 수 있도록)
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

# EKS 클러스터 생성
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_service_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids  # 퍼블릭 서브넷 ID들
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy,
    aws_iam_role_policy_attachment.eks_node_policy
  ]
}

# EKS 클러스터에서 사용할 EKS 노드 그룹
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.eks_node_policy
  ]
}
