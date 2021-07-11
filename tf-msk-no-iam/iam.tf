resource "aws_iam_policy" "client_auth_iam_policy" {
  name = "KafkaClientAuthorizationPolicy"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:AlterCluster",
          "kafka-cluster:Connect"
        ],
        Resource : aws_msk_cluster.msk_cluster_iam.arn
      },
      {
        Effect : "Allow",
        Action : [
          "kafka-cluster:*Topic*",
          "kafka-cluster:ReadData",
          "kafka-cluster:WriteData"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.msk_cluster_iam.cluster_name}/*"
      },
      {
        Effect : "Allow",
        Action : [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.msk_cluster_iam.cluster_name}/*"
      }
    ]
  })
}
