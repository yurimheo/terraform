# 1. IAM 사용자 생성
resource "aws_iam_user" "vpn_vpc_nginx_user" {
  name = "vpn-vpc-nginx-user"
}

# 2. 정책 정의 (VPC, VPN, EC2 관련 작업)
resource "aws_iam_policy" "vpn_vpc_nginx_policy" {
  name        = "vpn-vpc-nginx-policy"
  description = "Policy for managing VPN, VPC, and NGINX-related resources"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # VPC 관련 작업
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeVpcs",
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeRouteTables",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:ReplaceRouteTableAssociation",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        Resource = "*"
      },
      # 인터넷 게이트웨이 관련 작업
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeInternetGateways",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway"
        ],
        Resource = "*"
      },
      # 고객 게이트웨이 관련 작업
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeCustomerGateways",
          "ec2:CreateCustomerGateway",
          "ec2:DeleteCustomerGateway"
        ],
        Resource = "*"
      },
      # Site-to-Site VPN 관련 작업
      {
        Effect   = "Allow",
        Action   = [
          "ec2:CreateVpnGateway",
          "ec2:DeleteVpnGateway",
          "ec2:AttachVpnGateway",
          "ec2:DetachVpnGateway",
          "ec2:CreateVpnConnection",
          "ec2:DeleteVpnConnection",
          "ec2:DescribeVpnConnections",
          "ec2:DescribeVpnGateways"
        ],
        Resource = "*"
      },
      # Subnet 및 라우팅 관련 작업
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeSubnets",
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:DescribeRouteTables",
          "ec2:CreateRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable"
        ],
        Resource = "*"
      },
      # 네트워크 인터페이스 관련 작업 (추가됨)
      {
        Effect   = "Allow",
        Action   = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

# 3. 사용자와 정책 연결
resource "aws_iam_user_policy_attachment" "vpn_vpc_nginx_user_attachment" {
  user       = aws_iam_user.vpn_vpc_nginx_user.name
  policy_arn = aws_iam_policy.vpn_vpc_nginx_policy.arn
}

# 4. 액세스 키 생성
resource "aws_iam_access_key" "vpn_vpc_nginx_access_key" {
  user = aws_iam_user.vpn_vpc_nginx_user.name
}

output "vpn_vpc_nginx_access_key_id" {
  value     = aws_iam_access_key.vpn_vpc_nginx_access_key.id
  sensitive = true
}

output "vpn_vpc_nginx_secret_access_key" {
  value     = aws_iam_access_key.vpn_vpc_nginx_access_key.secret
  sensitive = true
}
