output "zookeeper_connect_string" {
  value = aws_msk_cluster.msk_cluster.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value = aws_msk_cluster.msk_cluster.bootstrap_brokers_tls
}

output "zookeeper_connect_string_iam" {
  value = aws_msk_cluster.msk_cluster_iam.zookeeper_connect_string
}

output "bootstrap_brokers_tls_iam" {
  description = "TLS connection host:port pairs"
  value = aws_msk_cluster.msk_cluster_iam.bootstrap_brokers_tls
}
