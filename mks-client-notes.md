# Amazon MSK Notes

Accessing an Amazon MSK cluster from EKS.

## Setup

1. Deploy MSK cluster and EKS cluster;
2. Create VPC Peering relationship between MSK and EKS VPCs;
3. Update routing tables for both VPCs and associated subnets to route traffic to CIDR range of opposite VPC;
4. Update default VPC security groups to allow traffic;
5. Update MSK security group to allow access to MSK ports (e.g., 2181, 2182, 9092, 9094, 9098) from EKS VPC CIDR range (
   e.g., 192.168.0.0/16);

## Create a 'Jump Box' EKS container

Deploy a Apache Tomcat container to EKS with OpenJDK 16 preinstalled.

```shell
kubectl apply -f ./resources/services/jump-box.yaml -n dev

kubectl get pods -n dev | grep jump-box
kubectl exec -n dev --stdin --tty jump-box-64466d5b9-4zfl2  -- /bin/bash
```

## Get Cluster Info

```shell
aws kafka list-clusters | jq -r '.ClusterInfoList[].ClusterArn'

aws kafka get-bootstrap-brokers \
    --cluster-arn $(aws kafka list-clusters | jq -r '.ClusterInfoList[0].ClusterArn')

aws kafka list-clusters | jq -r '.ClusterInfoList[0].ZookeeperConnectString'
```

## Install Kafka

```shell
kubectl get pods -n kafka
KAFKA_CONTAINER=<your_pod?>
kubectl describe pod $KAFKA_CONTAINER -n kafka

kubectl exec -it $KAFKA_CONTAINER -n kafka -- bash
```

<https://kafka.apache.org/quickstart>

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
wget https://downloads.apache.org/kafka/2.8.0/$KAFKA_PACKAGE.tgz
tar -xzf $KAFKA_PACKAGE.tgz
cd $KAFKA_PACKAGE
```

## Access MSK from the EKS Tomcat container client with TLS

```shell
# Java path specific for CMAK container
cp /usr/local/openjdk-16/lib/security/cacerts /tmp/kafka.client.truststore.jks
```

## Set up encryption for MSK in the EKS Tomcat container client

<https://docs.aws.amazon.com/msk/latest/developerguide/msk-working-with-encryption.html>

For non-IAM security.

```shell
kubectl cp ./kafka-config/client.properties \
  $KAFKA_CONTAINER:/usr/local/tomcat/$KAFKA_PACKAGE/bin/ -n kafka
```

For IAM-based security.

<https://aws.amazon.com/blogs/big-data/securing-apache-kafka-is-easy-and-familiar-with-iam-access-control-for-amazon-msk/>
<https://docs.aws.amazon.com/msk/latest/developerguide/iam-access-control.html#create-iam-access-control-policies>

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
kubectl cp ./kafka-config/client.properties \
  $KAFKA_CONTAINER:/usr/local/tomcat/$KAFKA_PACKAGE/bin/ -n kafka

kubectl cp ./kafka-config/client-iam.properties \
  $KAFKA_CONTAINER:/usr/local/tomcat/$KAFKA_PACKAGE/bin/ -n kafka
```


```shell
# bin/zookeeper-server-start.sh config/zookeeper.properties > /dev/null 2>&1 &
# bin/kafka-server-start.sh config/server.properties > /dev/null 2>&1 & 
```

Non-IAM Cluster.

```shell
export ZOOKPR="z-1.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:2181,z-2.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:2181,z-3.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:2181"
export BBROKERS="b-1.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094,b-2.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094,b-3.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094"

bin/kafka-topics.sh --create --topic demo-events \
    --partitions 3 --replication-factor 3 --zookeeper $ZOOKPR

bin/kafka-topics.sh --list --zookeeper $ZOOKPR

bin/kafka-topics.sh --describe --topic demo-events --zookeeper $ZOOKPR

bin/kafka-console-producer.sh --broker-list $BBROKERS \
    --producer.config bin/client.properties --topic demo-events

bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
    --consumer.config bin/client.properties --topic demo-events

bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
    --consumer.config bin/client.properties \
    --topic demo-events --from-beginning
```

IAM Cluster.

```shell
wget https://github.com/aws/aws-msk-iam-auth/releases/download/1.1.0/aws-msk-iam-auth-1.1.0-all.jar
mv aws-msk-iam-auth-1.1.0-all.jar libs/




export ZOOKPR="z-1.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:2181,z-2.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:2181,z-3.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:2181"
export BBROKERS="b-1.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:9098,b-2.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:9098"

bin/kafka-topics.sh --create --topic demo-events \
    --partitions 2 --replication-factor 2 --zookeeper $ZOOKPR \
    --command-config client-iam.properties

bin/kafka-topics.sh --delete --topic demo-events --zookeeper $ZOOKPR

bin/kafka-topics.sh --list --zookeeper $ZOOKPR

bin/kafka-topics.sh --describe --topic demo-events --zookeeper $ZOOKPR

bin/kafka-console-producer.sh --broker-list $BBROKERS \
    --producer.config bin/client-iam.properties --topic demo-events

bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
    --consumer.config bin/client-iam.properties --topic demo-events

bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
    --consumer.config bin/client-iam.properties \
    --topic demo-events --from-beginning
```