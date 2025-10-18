
output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "node_group_names" {
  value = [aws_eks_node_group.ng_a.node_group_name, aws_eks_node_group.ng_b.node_group_name]
}