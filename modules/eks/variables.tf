variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for EKS cluster"
  type        = list(string)
}
