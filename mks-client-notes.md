# Amazon MSK Notes

Accessing an Amazon MSK cluster from EKS.

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

aws kafka list-clusters | jq -r '.ClusterInfoList[].ZookeeperConnectString'
```

## Install Kafka

<https://kafka.apache.org/quickstart>

```shell
wget https://downloads.apache.org/kafka/2.8.0/kafka_2.13-2.8.0.tgz
tar -xzf kafka_2.13-2.8.0.tgz

cd kafka_2.13-2.8.0

bin/zookeeper-server-start.sh config/zookeeper.properties > /dev/null 2>&1 &
bin/kafka-server-start.sh config/server.properties > /dev/null 2>&1 & 
```

## Set up encryption for MSK in the EKS Tomcat container client

<https://docs.aws.amazon.com/msk/latest/developerguide/msk-working-with-encryption.html>

```shell
# Java path specific for CMAK container
cp /usr/local/openjdk-16/lib/security/cacerts /tmp/kafka.client.truststore.jks

echo "security.protocol=SSL" >> bin/client.properties
echo "ssl.truststore.location=/tmp/kafka.client.truststore.jks" >> bin/client.properties
cat bin/client.properties
```

## Access MSK from the EKS Tomcat container client with TLS

```shell
cd kafka_2.13-2.8.0

export ZOOKPR="z-2.demo-msk-cluster.v4qdw4.c7.kafka.us-east-1.amazonaws.com:2181,z-3.demo-msk-cluster.v4qdw4.c7.kafka.us-east-1.amazonaws.com:2181,z-1.demo-msk-cluster.v4qdw4.c7.kafka.us-east-1.amazonaws.com:2181"

export BBROKERS="b-3.demo-msk-cluster.v4qdw4.c7.kafka.us-east-1.amazonaws.com:9094,b-1.demo-msk-cluster.v4qdw4.c7.kafka.us-east-1.amazonaws.com:9094,b-2.demo-msk-cluster.v4qdw4.c7.kafka.us-east-1.amazonaws.com:9094"


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
