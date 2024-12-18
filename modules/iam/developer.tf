resource "aws_iam_user" "developer_user" {
  name = "developer_user"
  tags = {
    Role = "Developer"
  }
}

resource "aws_iam_policy" "developer_policy" {
  name        = "DeveloperPolicy"
  description = "Policy for Developers to manage EC2, S3, and Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ec2:*", "s3:*", "lambda:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "developer_policy_attachment" {
  user       = aws_iam_user.developer_user.name
  policy_arn = aws_iam_policy.developer_policy.arn
}