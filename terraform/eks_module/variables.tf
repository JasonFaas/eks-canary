variable "module_vpc_subnet_public_a_id" {
  description = "ID of the public subnet A in the VPC"
  type        = string
}

variable "module_vpc_subnet_public_b_id" {
  description = "ID of the public subnet B in the VPC"
  type        = string
}

variable "aws_sg_eks_cluster_id" {
  description = "Security group ID for EKS cluster communication"
  type        = string
}
