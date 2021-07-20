# Instructions

```shell
export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
export EKS_REGION="us-east-1"
export CLUSTER_NAME="eks-kafka-demo"

eksctl create cluster -f ./cluster.yaml
```