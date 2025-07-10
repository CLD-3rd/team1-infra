output "cluster_endpoint" {
  description = "EKS 클러스터 API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "클러스터 CA 데이터"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  description = "클러스터 보안그룹 ID"
  value       = module.eks.cluster_security_group_id
}

output "node_group_role_arn" {
  description = "노드 그룹 IAM Role ARN"
  value       = module.eks.eks_managed_node_groups["default"].iam_role_arn
}
