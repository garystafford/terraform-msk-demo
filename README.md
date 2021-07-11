# Terraform / Amazon MSK

Terraform project for Amazon Managed Streaming for Apache Kafka (Amazon MSK). Based on this [Terraform MSK Example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#example-usage).

_work in progress..._

![Graph](graphviz.png)

## Helpful AWS CLI Commands for Amazon MSK

```shell
aws kafka list-clusters

aws kafka list-clusters --query 'ClusterInfoList[*].ClusterArn'

aws kafka describe-cluster --cluster-arn <YOUR_ARN_HERE>

# assuming cluster 0 (first or single cluster)
aws kafka describe-cluster --cluster-arn $(aws kafka list-clusters --query 'ClusterInfoList[0].ClusterArn' --output text)
```

## Helm Chart

```shell
# perform dry run
helm install kafka-client ./kafka-client --namespace kafka --debug --dry-run

# apply chart resources
helm install kafka-client ./kafka-client --namespace kafka --create-namespace
```