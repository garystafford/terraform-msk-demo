# Terraform / Amazon MSK

Terraform project for Amazon Managed Streaming for Apache Kafka (Amazon MSK). Original Terraform code based on
this [Terraform MSK Example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster#example-usage)
.

_work in progress..._

![Graph](graphviz.png)

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

Deploy AWS resources.

```shell
cd ./tf-msk
terrafrom plan
terraform apply
```

## Helm Chart

Create a EKS-based Kafka client container.

```shell
export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
export EKS_REGION="us-east-1"
export CLUSTER_NAME="istio-observe-demo"

kubectl create namespace kafka

eksctl create iamserviceaccount \
  --name msk-serviceaccount \
  --namespace kafka \
  --region $AWS_REGION \
  --cluster $CLUSTER_NAME}\
  --attach-policy-arn arn:aws:iam::$AWS_ACCOUNT:policy/KafkaClientAuthorizationPolicy \
  --approve \
  --override-existing-serviceaccounts

eksctl get iamserviceaccount msk-serviceaccount --cluster $CLUSTER_NAME --namespace kafka

eksctl delete iamserviceaccount msk-serviceaccount --cluster $CLUSTER_NAME --namespace kafka
eksctl get iamserviceaccount --cluster $CLUSTER_NAME --namespace kafka

# kubectl get serviceaccount -n kafka
# kubectl describe serviceaccount msk-serviceaccount -n kafka
```

# perform dry run
helm install kafka-client ./kafka-client --namespace kafka --debug --dry-run

# apply chart resources
helm install kafka-client ./kafka-client --namespace kafka --create-namespace

# update
helm upgrade kafka-client ./kafka-client --namespace kafka
```