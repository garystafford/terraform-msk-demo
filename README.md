# Terraform / Amazon MSK

Terraform project for Amazon Managed Streaming for Apache Kafka (Amazon MSK). Original Terraform code based on
this [Terraform MSK Example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#example-usage)
.

_work in progress..._

![Graph](graphviz.png)

## Setup

1. Deploy MSK cluster and EKS cluster;
2. Create VPC Peering relationship between MSK and EKS VPCs;
3. Update routing tables for both VPCs and associated subnets to route traffic to CIDR range of opposite VPC;
4. Update default VPC security groups to allow traffic;
5. Update MSK security group to allow access to MSK ports (e.g., 2181, 2182, 9092, 9094, 9098) from EKS VPC CIDR range (
   e.g., 192.168.0.0/16);

## Helpful AWS CLI Commands for Amazon MSK

```shell
aws kafka list-clusters

aws kafka list-clusters --query 'ClusterInfoList[*].ClusterArn'

aws kafka describe-cluster --cluster-arn <YOUR_ARN_HERE>

# assuming cluster 0 (first or single cluster)
aws kafka describe-cluster --cluster-arn \
  $(aws kafka list-clusters --query 'ClusterInfoList[0].ClusterArn' --output text)
```

## Terraform

Deploy AWS MSK resources.

```shell
cd ./tf-msk
terraform validate
terrafrom plan
terraform apply
```

## Helm Chart

Create a EKS-based Kafka client container in an existing EKS cluster.

```shell
export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
export EKS_REGION="us-east-1"
export CLUSTER_NAME="istio-observe-demo"

kubectl create namespace kafka

eksctl create iamserviceaccount \
  --name msk-serviceaccount \
  --namespace kafka \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT:policy/KafkaClientAuthorizationPolicy \
  --approve \
  --override-existing-serviceaccounts

eksctl get iamserviceaccount --cluster $CLUSTER_NAME --namespace kafka
eksctl get iamserviceaccount msk-serviceaccount --cluster $CLUSTER_NAME --namespace kafka

# eksctl delete iamserviceaccount msk-serviceaccount --cluster $CLUSTER_NAME --namespace kafka

# perform dry run
helm install kafka-client ./kafka-client --namespace kafka --debug --dry-run

# apply chart resources
helm install kafka-client ./kafka-client --namespace kafka --create-namespace

# update
helm upgrade kafka-client ./kafka-client --namespace kafka
```