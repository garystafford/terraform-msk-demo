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
          "kafka:ListScramSecrets",
          "kafka:DescribeCluster",
          "kafka:GetBootstrapBrokers",
          "kafka:BatchDisassociateScramSecret",
          "kafka:RebootBroker",
          "kafka:BatchAssociateScramSecret",
          "kafka:ListNodes",
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/*/*"
      },
      {
        Effect : "Allow",
        Action: [
          "kafka:ListClusterOperations"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:/v1/clusters/*"
      },
      {
        Effect : "Allow",
        Action: [
          "kafka:ListClusters"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:/v1/clusters"
      },
      {
        Effect : "Allow",
        Action: [
          "kafka:ListKafkaVersion"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:/v1/kafka-versions"
      },
      {
        Effect : "Allow",
        Action: [
          "kafka:DescribeConfiguration"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:/v1/configurations/*"
      },
      {
        Effect : "Allow",
        Action: [
          "kafka:DescribeClusterOperation"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:/v1/operations/*"
      },
      {
        Effect : "Allow",
        Action: [
          "kafka:ListConfigurationRevisions"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:/v1/configurations/*/revisions"
      },
      {
        Effect : "Allow",
        Action: [
          "kafka:DescribeConfigurationRevision"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:/v1/configurations/*/revisions/*"
      },
      {
        Effect : "Allow",
        Action: [
          "kafka:GetCompatibleKafkaVersions"
        ],
        Resource : "arn:aws:kafka:${var.region}:${data.aws_caller_identity.current.account_id}:/v1/compatible-kafka-versions"
      }
    ]
  })
}