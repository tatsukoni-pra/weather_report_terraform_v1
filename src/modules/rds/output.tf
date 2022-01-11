output "cluster_id" {
  value = aws_rds_cluster.service_cluster.id
  description = "Cluster Id For DB cluster identifier"
}

output "cluster_arn" {
  value = aws_rds_cluster.service_cluster.arn
  description = "Cluster Arn For DB cluster identifier"
}
