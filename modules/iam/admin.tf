provider "aws" {
  region = "ap-northeast-2" 
}

resource "aws_iam_user" "admin_user" {
  name = "admin-user"
}

resource "aws_iam_user_policy_attachment" "admin_policy_attachment" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "admin_access_key" {
  user = aws_iam_user.admin_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.admin_access_key.id
  sensitive = true
}

output "secret_access_key" {
  value = aws_iam_access_key.admin_access_key.secret
  sensitive = true
}
