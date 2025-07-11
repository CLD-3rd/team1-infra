output "cluster_id" {
  description = "생성된 EKS 클러스터의 ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "생성된 EKS 클러스터의 ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "생성된 EKS 클러스터의 엔드포인트 URL"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "생성된 EKS 클러스터의 인증 기관 데이터 (base64 인코딩)"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_name" {
  description = "생성된 EKS 클러스터의 이름"
  value       = aws_eks_cluster.this.name
}

output "cluster_security_group_id" {
  description = "EKS sg id"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}
