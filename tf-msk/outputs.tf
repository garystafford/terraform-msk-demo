output "zookeeper_connect_string_no_iam" {
  description = "Apache ZooKeeper connection"
  value       = aws_msk_cluster.msk_cluster.zookeeper_connect_string
}

output "bootstrap_brokers_tls_no_iam" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.msk_cluster.bootstrap_brokers_tls
}

output "zookeeper_connect_string_iam" {
  description = "Apache ZooKeeper connection IAM"
  value       = aws_msk_cluster.msk_cluster_iam.zookeeper_connect_string
}

output "bootstrap_brokers_sasl_iam" {
  description = "SASL IAM connection host:port pairs"
  value       = aws_msk_cluster.msk_cluster_iam.bootstrap_brokers_sasl_iam
}

output "zookeeper_connect_string_scram" {
  description = "Apache ZooKeeper connection SCRAM"
  value       = aws_msk_cluster.msk_cluster_scram.zookeeper_connect_string
}

output "bootstrap_brokers_sasl_scram" {
  description = "SASL SCRAM connection host:port pairs"
  value       = aws_msk_cluster.msk_cluster_scram.bootstrap_brokers_sasl_scram
}
