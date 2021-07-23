# Instructions

# Create Cluster

```shell
export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
export EKS_REGION="us-east-1"
export CLUSTER_NAME="eks-kafka-demo"

eksctl create cluster -f ./cluster.yaml
```

## Delete Cluster

```shell
eksctl delete cluster --region=us-east-1 --name=eks-kafka-demo
```