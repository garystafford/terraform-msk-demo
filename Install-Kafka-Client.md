# Amazon MSK Notes

## Install and Configure Kafka Client

```shell
kubectl get pods -n kafka
KAFKA_CONTAINER=<your_pod>
kubectl describe pod $KAFKA_CONTAINER -n kafka

kubectl exec -it $KAFKA_CONTAINER -n kafka -- bash
```

Optional: Install AWS CLI v2
```shell
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
echo "export PATH=/usr/local/bin:$PATH" >> ~/.bashrc
echo "AWS_PAGER=" >> ~/.bashrc
source ~/.bashrc
apt update
apt install less
```

Optional: Check your Identity

```shell
aws sts get-caller-identity
```

<https://kafka.apache.org/quickstart>

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
wget https://downloads.apache.org/kafka/2.8.0/$KAFKA_PACKAGE.tgz
tar -xzf $KAFKA_PACKAGE.tgz
```

## Set up encryption for MSK in the EKS Tomcat container client

<https://docs.aws.amazon.com/msk/latest/developerguide/msk-working-with-encryption.html>

```shell
# Java path specific for CMAK container
cp /usr/local/openjdk-16/lib/security/cacerts /tmp/kafka.client.truststore.jks
exit
```

Install client properties for non-IAM cluster security.

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
PROPERTIES_FILE="./kafka-config/client.properties"
kubectl cp ${PROPERTIES_FILE} \
  $KAFKA_CONTAINER:/usr/local/tomcat/$KAFKA_PACKAGE/bin/ -n kafka
```

Install client properties for IAM auth cluster security.

<https://aws.amazon.com/blogs/big-data/securing-apache-kafka-is-easy-and-familiar-with-iam-access-control-for-amazon-msk/>
<https://docs.aws.amazon.com/msk/latest/developerguide/iam-access-control.html#create-iam-access-control-policies>
<https://github.com/aws/aws-msk-iam-auth/blob/71798fc5b7e08d12e6beb48a6f0864eb27f04ebb/src/main/java/software/amazon/msk/auth/iam/internals/MSKCredentialProvider.java#L43>

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
PROPERTIES_FILE="./kafka-config/client-iam.properties"
kubectl cp ${PROPERTIES_FILE} \
  $KAFKA_CONTAINER:/usr/local/tomcat/$KAFKA_PACKAGE/bin/ -n kafka
```

Install client properties for OIDC auth cluster security.

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
PROPERTIES_FILE="./kafka-config/client-oidc.properties"
sed -i "" "s/AWS_ACCOUNT/${AWS_ACCOUNT}/g" ${PROPERTIES_FILE}
kubectl cp ${PROPERTIES_FILE} \
  $KAFKA_CONTAINER:/usr/local/tomcat/$KAFKA_PACKAGE/bin/ -n kafka
```

Working with a Non-IAM Cluster.

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
PROPERTIES_FILE="bin/client.properties"

cd $KAFKA_PACKAGE

export ZOOKPR="z-1.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:2181,z-2.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:2181,z-3.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:2181"
export BBROKERS="b-1.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094,b-2.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094,b-3.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094"

bin/kafka-topics.sh --create --topic demo-events \
    --partitions 3 --replication-factor 3 --zookeeper $ZOOKPR

bin/kafka-topics.sh --list --zookeeper $ZOOKPR

bin/kafka-topics.sh --describe --topic demo-events --zookeeper $ZOOKPR

bin/kafka-console-producer.sh --broker-list $BBROKERS \
    --producer.config $PROPERTIES_FILE --topic demo-events

bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
    --consumer.config $PROPERTIES_FILE --topic demo-events

bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
    --consumer.config $PROPERTIES_FILE \
    --topic demo-events --from-beginning
```

Working with an IAM Cluster.

```shell
# install latest aws-msk-iam-auth jar in kafka classpath
KAFKA_PACKAGE=kafka_2.13-2.8.0
PROPERTIES_FILE="bin/client-iam.properties"
# PROPERTIES_FILE="bin/client-oidc.properties"

cd $KAFKA_PACKAGE

wget https://github.com/aws/aws-msk-iam-auth/releases/download/1.1.0/aws-msk-iam-auth-1.1.0-all.jar
mv aws-msk-iam-auth-1.1.0-all.jar libs/

export ZOOKPR="z-1.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:2181,z-2.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:2181,z-3.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:2181"
export BBROKERS="b-1.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:9098,b-2.demo-msk-cluster-iam.99s971.c2.kafka.us-east-1.amazonaws.com:9098"

bin/kafka-topics.sh --create --topic demo-events-iam \
    --partitions 2 --replication-factor 2 --zookeeper $ZOOKPR \
    --command-config $PROPERTIES_FILE

# bin/kafka-topics.sh --delete --topic demo-events-iam --zookeeper $ZOOKPR

bin/kafka-topics.sh --list --zookeeper $ZOOKPR

bin/kafka-topics.sh --describe --topic demo-events --zookeeper $ZOOKPR

bin/kafka-console-producer.sh --broker-list $BBROKERS \
    --producer.config $PROPERTIES_FILE --topic demo-events-iam

bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
    --consumer.config $PROPERTIES_FILE --topic demo-events-iam

bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
    --consumer.config $PROPERTIES_FILE \
    --topic demo-events-iam --from-beginning
```

Successful Output Example

```text
root@kafka-client-oidc-6b7b88cc94-82mbf:/usr/local/tomcat/kafka_2.13-2.8.0# bin/kafka-console-producer.sh --broker-list $BBROKERS \
>     --producer.config bin/client-iam.properties --topic demo-events-iam
>Test of OIDC
>^C

root@kafka-client-oidc-6b7b88cc94-82mbf:/usr/local/tomcat/kafka_2.13-2.8.0# bin/kafka-console-consumer.sh --bootstrap-server $BBROKERS \
>     --consumer.config bin/client-iam.properties \
>     --topic demo-events-iam --from-beginning
Test of OIDC
^C
Processed a total of 1 messages
```
Unused.

```shell
# bin/zookeeper-server-start.sh config/zookeeper.properties > /dev/null 2>&1 &
# bin/kafka-server-start.sh config/server.properties > /dev/null 2>&1 & 
```
