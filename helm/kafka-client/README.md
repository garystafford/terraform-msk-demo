# Helm Chart: kafka-client

Deploys two `tomcat:10.0.8-jdk16-openjdk` containers, which are then configured as a Kafka client producer and consumer.

## Container 1

Intended to be configured for use with an IAM Policy for auth with OIDC. Container 1 uses the `msk-serviceaccount` Service Account. See the `eks_msk_policy.tf` file for the IAM Policy, `KafkaClientAuthorizationPolicy`.

## Container 2

Intended to be configured for use with an existing IAM Role for auth with OIDC. Container 2 uses the `msk-oidc-serviceaccount` Service Account. See the `eks_msk_role.tf` file for the IAM Role, `EksKafkaOidcRole`, which is associated with the IAM Policy, `KafkaClientAuthorizationPolicy`.

## IAM Role for Service Account (IRSA)

For using IAM auth with EKS and MSK, with or without an existing role.

```shell
export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
export EKS_REGION="us-east-1"
export CLUSTER_NAME="istio-observe-demo"
export NAMESPACE="kafka"

kubectl create namespace $NAMESPACE

# iam policy associated with service account
eksctl create iamserviceaccount \
  --name msk-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT}:policy/KafkaClientAuthorizationPolicy" \
  --approve \
  --override-existing-serviceaccounts

# existing iam role associated with service account
eksctl create iamserviceaccount \
  --name msk-oidc-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-role-arn "arn:aws:iam::${AWS_ACCOUNT}:role/EksKafkaOidcRole" \
  --approve \
  --override-existing-serviceaccounts

# access secrets manager for sasl scram
eksctl create iamserviceaccount \
  --name msk-sasl-scram-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT}:policy/EksScramSecretManagerPolicy" \
  --approve \
  --override-existing-serviceaccounts

# confirm successful creation of accounts
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

kubectl get pods -n kafka -l app=kafka-client -w
```