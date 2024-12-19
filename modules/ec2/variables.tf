variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the EC2 instance will be deployed"
  type        = string
}
