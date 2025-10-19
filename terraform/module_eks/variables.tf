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
  default = ""
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

# aws_eks_cluster_role_arn
variable "aws_eks_cluster_role_arn" {
  description = "ARN of the EKS cluster role"
  type        = string
} 

variable "aws_eks_node_role_arn" {
  description = "ARN of the EKS node role"
  type        = string
}

# lb_created
variable "lb_created" {
  description = "Whether the LoadBalancer was created"
  type        = bool
}
  