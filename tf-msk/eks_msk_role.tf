resource "aws_iam_role" "eks_kafka_demo_app_oidc_role" {
  name = "EKSKafkaDemoAppRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : var.oidc_arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            "${var.oidc_id}" : "system:serviceaccount:${var.eks_namespace}:kafka-demo-app-sasl-scram-serviceaccount"
          }
        }
      },
      {
        Effect : "Allow",
        Principal : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EKSKafkaDemoAppRole"
        },
        Action : "sts:AssumeRole",
        Condition : {}
      }
    ]
  })

  tags = {
    Name = "EKS Kafka Demo App OIDC Role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_kafka_oidc_role_attach" {
  role       = aws_iam_role.eks_kafka_demo_app_oidc_role.name
  policy_arn = aws_iam_policy.kafka_demo_app_policy.arn
}

resource "aws_iam_role" "eks_kafka_client_msk_oidc_role" {
  name = "EKSKafkaClientMSKRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : var.oidc_arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            "${var.oidc_id}" : "system:serviceaccount:${var.eks_namespace}:kafka-client-msk-sasl-scram-serviceaccount"
          }
        }
      },
      {
        Effect : "Allow",
        Principal : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/EKSKafkaClientMSKRole"
        },
        Action : "sts:AssumeRole",
        Condition : {}
      }
    ]
  })

  tags = {
    Name = "EKS Kafka Client MSK OIDC Role"
  }
}

resource "aws_iam_role_policy_attachment" "kafka_client_msk_policy_attach" {
  role       = aws_iam_role.eks_kafka_client_msk_oidc_role.name
  policy_arn = aws_iam_policy.kafka_client_msk_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_client_secretmanager_policy_attach" {
  role       = aws_iam_role.eks_kafka_client_msk_oidc_role.name
  policy_arn = aws_iam_policy.eks_client_secretmanager_policy.arn
}
