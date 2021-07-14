# Helm Chart: kafka-client

Deploys two `tomcat:10.0.8-jdk16-openjdk` containers, which are then configured as a Kafka client producer and consumer.

## Container 1

Intended to be configured for use with an IAM Policy for auth. Container 1 uses the `msk-serviceaccount` Service Account. See the `iam.tf` file for the IAM Policy, `KafkaClientAuthorizationPolicy`.

## Container 2

Intended to be configured for use with OIDC for auth. Container 2 uses the `msk-oidc-serviceaccount` Service Account. See the `oidc.tf` file for the IAM Role, `EksKafkaOidcRole`, which is associated with the IAM Policy, `KafkaClientAuthorizationPolicy`.

## IAM Role for Service Account (IRSA)

For using IAM and OIDC auth with EKS and MSK.

```shell
export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
export EKS_REGION="us-east-1"
export CLUSTER_NAME="istio-observe-demo"
export NAMESPACE="kafka"

kubectl create namespace $NAMESPACE

# iam
eksctl create iamserviceaccount \
  --name msk-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT}:policy/KafkaClientAuthorizationPolicy" \
  --approve \
  --override-existing-serviceaccounts

# oidc
eksctl create iamserviceaccount \
  --name msk-oidc-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-role-arn "arn:aws:iam::${AWS_ACCOUNT}:role/EksKafkaOidcRole" \
  --approve \
  --override-existing-serviceaccounts

eksctl get iamserviceaccount --cluster $CLUSTER_NAME --namespace $NAMESPACE
eksctl get iamserviceaccount msk-serviceaccount --cluster $CLUSTER_NAME --namespace $NAMESPACE
kubectl get serviceaccount -n kafka

# eksctl delete iamserviceaccount msk-oidc-serviceaccount --cluster $CLUSTER_NAME --namespace $NAMESPACE
```

## Deploy Helm Chart

Create a EKS-based Kafka client container in an existing EKS cluster.

```shell
# perform dry run
helm install kafka-client ./kafka-client --namespace $NAMESPACE --debug --dry-run

# apply chart resources
helm install kafka-client ./kafka-client --namespace $NAMESPACE --create-namespace

# optional: update
helm upgrade kafka-client ./kafka-client --namespace $NAMESPACE

kubectl get pods -n kafka
```