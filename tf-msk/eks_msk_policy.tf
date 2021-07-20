resource "aws_iam_policy" "kafka_demo_app_policy" {
  name = "EKSKafkaDemoAppPolicy"
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
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${aws_msk_cluster.msk_cluster_iam.cluster_name}/*"
      },
      {
        Effect : "Allow",
        Action : [
          "kafka-cluster:*Topic*",
          "kafka-cluster:ReadData",
          "kafka-cluster:WriteData"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.msk_cluster_iam.cluster_name}/*/*"
      },
      {
        Effect : "Allow",
        Action : [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:group/${aws_msk_cluster.msk_cluster_iam.cluster_name}/*/*"
      }
    ]
  })
}

resource "aws_iam_policy" "kafka_client_msk_policy" {
  name = "EKSKafkaClientMSKPolicy"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action: [
          "kafka:ListTagsForResource",
          "kafka:GetCompatibleKafkaVersions",
          "kafka:DescribeConfigurationRevision",
          "kafka:ListClusters",
          "kafka:DescribeConfiguration",
          "kafka:ListScramSecrets",
          "kafka:DescribeCluster",
          "kafka:ListKafkaVersions",
          "kafka:GetBootstrapBrokers",
          "kafka:ListConfigurations",
          "kafka:BatchDisassociateScramSecret",
          "kafka:RebootBroker",
          "kafka:BatchAssociateScramSecret",
          "kafka:DescribeClusterOperation",
          "kafka:ListConfigurationRevisions",
          "kafka:ListNodes",
          "kafka:ListClusterOperations"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/*/*"
      }
    ]
  })
}