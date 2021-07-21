# Amazon MSK Notes

## References

- <https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html>
- <https://eksctl.io/usage/iamserviceaccounts/>

## Install and Configure Kafka Client

```shell
kubectl get pods -n kafka
export KAFKA_CONTAINER=$(kubectl get pods -n kafka -l app=kafka-client | awk 'FNR == 2 {print $1}')
# export KAFKA_CONTAINER=$(kubectl get pods -n kafka -l app=kafka-client-oidc | awk 'FNR == 2 {print $1}')
echo $KAFKA_CONTAINER

kubectl describe pod $KAFKA_CONTAINER -n kafka

kubectl exec -it $KAFKA_CONTAINER -n kafka -- bash
```

<https://kafka.apache.org/quickstart>

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
wget -qO- https://downloads.apache.org/kafka/2.8.0/$KAFKA_PACKAGE.tgz | tar -xzf -
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

Install client properties for IAM-based auth with IAM Policy for security.

<https://aws.amazon.com/blogs/big-data/securing-apache-kafka-is-easy-and-familiar-with-iam-access-control-for-amazon-msk/>
<https://docs.aws.amazon.com/msk/latest/developerguide/iam-access-control.html#create-iam-access-control-policies>
<https://github.com/aws/aws-msk-iam-auth/blob/71798fc5b7e08d12e6beb48a6f0864eb27f04ebb/src/main/java/software/amazon/msk/auth/iam/internals/MSKCredentialProvider.java#L43>

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
PROPERTIES_FILE="./kafka-config/client-iam.properties"
kubectl cp ${PROPERTIES_FILE} \
  $KAFKA_CONTAINER:/usr/local/tomcat/$KAFKA_PACKAGE/bin/ -n kafka
```

Install client properties for IAM-based auth with existing IAM Role for security.

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

export ZOOKPR=$(aws ssm get-parameter --name /msk/scram/zookeeper --query 'Parameter.Value' --output text)
export BBROKERS=$(aws ssm get-parameter --name /msk/scram/brokers --query 'Parameter.Value' --output text)

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

Working with an IAM Cluster (W/ or w/o existing IAM Role).

```shell
KAFKA_PACKAGE=kafka_2.13-2.8.0
PROPERTIES_FILE="bin/client-iam.properties"
# PROPERTIES_FILE="bin/client-oidc.properties" # existing IAM role
cd $KAFKA_PACKAGE

# install latest aws-msk-iam-auth jar in kafka classpath for IAM
wget https://github.com/aws/aws-msk-iam-auth/releases/download/1.1.0/aws-msk-iam-auth-1.1.0-all.jar
mv aws-msk-iam-auth-1.1.0-all.jar libs/

export ZOOKPR=$(aws ssm get-parameter --name /msk/scram/zookeeper --query 'Parameter.Value' --output text)
export BBROKERS=$(aws ssm get-parameter --name /msk/scram/brokers --query 'Parameter.Value' --output text)

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

Optional: Install AWS CLI v2.

```shell
apt update
yes | apt install wget unzip less groff
wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
unzip awscli-exe-linux-x86_64.zip
./aws/install
echo "export PATH=/usr/local/bin:$PATH" >> ~/.bashrc
echo "AWS_PAGER=" >> ~/.bashrc
source ~/.bashrc
```

Optional: Check your Identity.

```shell
aws sts get-caller-identity
```

Unused, to start Kafka locally vs. MSK.

```shell
bin/zookeeper-server-start.sh config/zookeeper.properties > /dev/null 2>&1 &
bin/kafka-server-start.sh config/server.properties > /dev/null 2>&1 & 
```


Using Kafka Client for MSK.

```shell
export KAFKA_CONTAINER=$(kubectl get pods -n kafka -l app=kafka-client-msk | awk 'FNR == 2 {print $1}')
kubectl exec -it $KAFKA_CONTAINER -n kafka -- bash

export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')

PROPERTIES_FILE="bin/client-oidc.properties"
sed -i "s/AWS_ACCOUNT/${AWS_ACCOUNT}/g" ${PROPERTIES_FILE}

export ZOOKPR=$(aws ssm get-parameter --name /msk/scram/zookeeper --query 'Parameter.Value' --output text)
export BBROKERS=$(aws ssm get-parameter --name /msk/scram/brokers --query 'Parameter.Value' --output text)
export DISTINGUISHED_NAME=$(echo $BBROKERS | awk -F' '  '{print $1}' | sed 's/b-1/*/g')

bin/kafka-topics.sh --list --zookeeper $ZOOKPR

# KAFKA ACLs
# https://docs.aws.amazon.com/msk/latest/developerguide/msk-acls.html
# https://cwiki.apache.org/confluence/display/KAFKA/Kafka+Authorization+Command+Line+Interface

# add read
bin/kafka-acls.sh \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --add \
  --allow-principal "User:CN=${DISTINGUISHED_NAME}" \
  --operation Read \
  --group=consumer-group-B \
  --topic foo-topic

bin/kafka-acls.sh \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --add \
  --allow-principal "User:CN=${DISTINGUISHED_NAME}" \
  --operation Read \
  --group=consumer-group-A \
  --topic bar-topic

# add write
bin/kafka-acls.sh \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --add \
  --allow-principal "User:CN=${DISTINGUISHED_NAME}" \
  --operation Write \
  --topic foo-topic

bin/kafka-acls.sh \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --add \
  --allow-principal "User:CN=${DISTINGUISHED_NAME}" \
  --operation Write \
  --topic bar-topic


export USER=tierlenticar
## add read
#bin/kafka-acls.sh \
#  --authorizer-properties zookeeper.connect=$ZOOKPR \
#  --add \
#  --allow-principal User:$USER \
#  --operation Read \
#  --group=consumer-group-B \
#  --topic foo-topic
#
#bin/kafka-acls.sh \
#  --authorizer-properties zookeeper.connect=$ZOOKPR \
#  --add \
#  --allow-principal User:$USER \
#  --operation Read \
#  --group=consumer-group-A \
#  --topic bar-topic

## add write
#bin/kafka-acls.sh \
#  --authorizer-properties zookeeper.connect=$ZOOKPR \
#  --add \
#  --allow-principal User:$USER \
#  --operation Write \
#  --topic foo-topic
#
#bin/kafka-acls.sh \
#  --authorizer-properties zookeeper.connect=$ZOOKPR \
#  --add \
#  --allow-principal User:$USER \
#  --operation Write \
#  --topic bar-topic

# producers and consumers
bin/kafka-acls.sh \
  --authorizer kafka.security.auth.SimpleAclAuthorizer \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --add \
  --allow-principal User:$USER \
  --producer \
  --topic foo-topic

bin/kafka-acls.sh \
  --authorizer kafka.security.auth.SimpleAclAuthorizer \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --add \
  --allow-principal User:$USER \
  --producer \
  --topic bar-topic

bin/kafka-acls.sh \
  --authorizer kafka.security.auth.SimpleAclAuthorizer \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --add \
  --allow-principal User:$USER \
  --consumer \
  --topic foo-topic \
  --group consumer-group-B

bin/kafka-acls.sh \
  --authorizer kafka.security.auth.SimpleAclAuthorizer \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --add \
  --allow-principal User:$USER \
  --consumer \
  --topic bar-topic \
  --group consumer-group-A

# list
bin/kafka-acls.sh \
  --authorizer kafka.security.auth.SimpleAclAuthorizer \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --list

bin/kafka-acls.sh \
  --authorizer kafka.security.auth.SimpleAclAuthorizer \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --list \
  --topic foo-topic

# remove
bin/kafka-acls.sh \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --remove \
  --topic foo-topic

bin/kafka-acls.sh \
  --authorizer kafka.security.auth.SimpleAclAuthorizer \
  --authorizer-properties zookeeper.connect=$ZOOKPR \
  --remove \
  --allow-principal "User:CN=${DISTINGUISHED_NAME}" \
  --operation Read \
  --topic foo-topic

```
