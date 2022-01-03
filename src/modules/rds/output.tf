output "cluster_id" {
  value = aws_rds_cluster.service_cluster.id
  description = "Cluster Id For DB cluster identifier"
}
