

output subnet_public_a_id {
    value = aws_subnet.public_a.id
}

output subnet_public_b_id {
    value = aws_subnet.public_b.id
}

output aws_sg_eks_cluster_id {
    value = aws_security_group.eks_cluster.id
}

output aws_eks_cluster_role_arn {
    value = aws_iam_role.eks_cluster.arn
}

output aws_eks_node_role_arn {
    value = aws_iam_role.nodes.arn
}