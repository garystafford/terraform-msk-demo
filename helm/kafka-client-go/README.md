# Helm Chart: kafka-demo-app and kafka-client-msk

## IAM Role for Service Account (IRSA)

```shell
export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
export EKS_REGION="us-east-1"
export CLUSTER_NAME="istio-observe-demo"
export NAMESPACE="kafka"

kubectl create namespace $NAMESPACE

# kafka-demo-app: iam policy associated with service account
eksctl create iamserviceaccount \
  --name kafka-demo-app-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT}:policy/EKSKafkaDemoAppPolicy" \
  --approve \
  --override-existing-serviceaccounts

# kafka-demo-app: existing iam role associated with service account
eksctl create iamserviceaccount \
  --name kafka-demo-app-oidc-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-role-arn "arn:aws:iam::${AWS_ACCOUNT}:role/EKSKafkaDemoAppRole" \
  --approve \
  --override-existing-serviceaccounts

# kafka-demo-app: access secrets manager for sasl scram
eksctl create iamserviceaccount \
  --name kafka-demo-app-sasl-scram-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT}:policy/EKSScramSecretManagerPolicy" \
  --approve \
  --override-existing-serviceaccounts

# kafka-client-msk: access msk and secrets manager for sasl scram
eksctl create iamserviceaccount \
  --name kafka-client-msk-sasl-scram-serviceaccount \
  --namespace $NAMESPACE \
  --region $EKS_REGION \
  --cluster $CLUSTER_NAME \
  --attach-role-arn "arn:aws:iam::${AWS_ACCOUNT}:role/EKSKafkaClientMSKRole" \
  --approve \
  --override-existing-serviceaccounts

# confirm successful creation of accounts
eksctl get iamserviceaccount --cluster $CLUSTER_NAME --namespace $NAMESPACE
eksctl get iamserviceaccount msk-serviceaccount --cluster $CLUSTER_NAME --namespace $NAMESPACE
kubectl get serviceaccount -n kafka

# eksctl delete iamserviceaccount <iamserviceaccount_name> --cluster $CLUSTER_NAME --namespace $NAMESPACE
```

```text
➜  tf-msk git:(master) ✗ kubectl get serviceaccounts -n kafka
NAME                                         SECRETS   AGE
default                                      1         8d
kafka-client-msk-sasl-scram-serviceaccount   1         2m14s
kafka-demo-app-oidc-serviceaccount           1         2m53s
kafka-demo-app-sasl-scram-serviceaccount     1         2m16s
kafka-demo-app-serviceaccount                1         2m56s
```

## Create Topics using Kafka Client

```shell
bin/kafka-topics.sh --create --topic ba-topic --partitions 2 --replication-factor 2 --zookeeper $ZOOKPR
bin/kafka-topics.sh --create --topic ba-topic --partitions 2 --replication-factor 2 --zookeeper $ZOOKPR
bin/kafka-topics.sh --list --zookeeper $ZOOKPR
```


## Deploy Helm Chart

Create a EKS-based Kafka client container in an existing EKS cluster.

```shell
# perform dry run
helm install kafka-client-go ./kafka-client-go --namespace $NAMESPACE --debug --dry-run

# apply chart resources
helm install kafka-client-go ./kafka-client-go --namespace $NAMESPACE --create-namespace

# optional: update
helm upgrade kafka-client-go ./kafka-client-go --namespace $NAMESPACE

kubectl get pods -n kafka -l app=kafka-client-consumer -w
kubectl describe pod -n kafka -l app=kafka-client-consumer
```