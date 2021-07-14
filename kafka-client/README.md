# Helm Chart: kafka-client

Deploys two `tomcat:10.0.8-jdk16-openjdk` containers, which can be configured as a Kafka client producer and consumer.

## Container 1

Intended to be configured for use with an IAM Role for auth. It uses `serviceAccountName: msk-serviceaccount` See the `iam.tf` file for the IAM Role and Policy.

## Container 2

Intended to be configured for use with OIDC for auth. It uses `serviceAccountName: msk-oidc-serviceaccount`. See the `oidc.tf` file for the IAM Role and Policy.