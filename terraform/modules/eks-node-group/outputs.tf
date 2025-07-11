# EKS Node Group Module Outputs

output "node_group_id" {
  description = "생성된 EKS 노드 그룹의 ID"
  value       = aws_eks_node_group.this.id
}

output "node_group_arn" {
  description = "생성된 EKS 노드 그룹의 ARN"
  value       = aws_eks_node_group.this.arn
}

output "node_group_status" {
  description = "생성된 EKS 노드 그룹의 상태"
  value       = aws_eks_node_group.this.status
}
