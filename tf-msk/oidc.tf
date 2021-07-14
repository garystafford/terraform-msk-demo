resource "aws_iam_role" "eks_kafka_oidc_role" {
  name = "EksKafkaOidcRole"

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
            "${var.oidc_id}" : "system:serviceaccount:${var.eks_namespace}:msk-oidc-serviceaccount"
          }
        }
      }
    ]
  })


  tags = {
    Name = "EKS Kafka OIDC Role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_kafka_oidc_role_attach" {
  role       = aws_iam_role.eks_kafka_oidc_role.name
  policy_arn = aws_iam_policy.client_auth_iam_policy.arn
}
