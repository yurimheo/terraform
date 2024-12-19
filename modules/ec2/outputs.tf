output "ec2_id" {
  value = aws_instance.ec2.id
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "security_group_id" {
  value = aws_security_group.web_sg.id
}
