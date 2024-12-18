resource "aws_iam_user" "admin_user" {
  name = "admin_user"
  tags = {
    Role = "Admin"
  }
}

resource "aws_iam_user_policy_attachment" "admin_policy" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}