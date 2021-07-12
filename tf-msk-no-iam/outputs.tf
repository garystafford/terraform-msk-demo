output "zookeeper_connect_string" {
  description = "Apache ZooKeeper connection"
  value = aws_msk_cluster.msk_cluster.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value = aws_msk_cluster.msk_cluster.bootstrap_brokers_tls
}

output "zookeeper_connect_string_iam" {
  description = "Apache ZooKeeper connection"
  value = aws_msk_cluster.msk_cluster_iam.zookeeper_connect_string
}

output "bootstrap_brokers_sasl_iam" {
  description = "SASL IAM connection host:port pairs"
  value = aws_msk_cluster.msk_cluster_iam.bootstrap_brokers_sasl_iam
}
