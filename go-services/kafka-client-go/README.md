# Kafka Client Producer/Consumer Combination Demo App

## Test in Kubernetes Container without Compiling

### Code References

- <https://www.sohamkamani.com/golang/working-with-kafka/>
- <https://github.com/sohamkamani/golang-kafka-example/>
- <https://github.com/segmentio/kafka-go>
- <https://docs.aws.amazon.com/msk/latest/developerguide/msk-password.html>
- <https://github.com/eshepelyuk/cmak-operator>

### Copy Go Files to Container

```shell
export KAFKA_CONTAINER=$(kubectl get pods -n kafka -l app=kafka-client-consumer | awk 'FNR == 2 {print $1}')

kubectl cp main.go $KAFKA_CONTAINER:/root -n kafka
kubectl cp tls.go $KAFKA_CONTAINER:/root -n kafka
kubectl cp producer.go $KAFKA_CONTAINER:/root -n kafka
kubectl cp consumer.go $KAFKA_CONTAINER:/root -n kafka
```

### Build and Test App in Container

```shell
kubectl exec -it $KAFKA_CONTAINER -n kafka -- bash

cd ~
go mod init kafka-client
go mod tidy

go run kafka-client
```

### Build and Push Docker Image

```shell
time docker build -t garystafford/kafka-demo-service:1.0.0 . --no-cache
docker push garystafford/kafka-demo-service:1.0.0

time docker build -t garystafford/kafka-demo-service:1.1.0-scram . --no-cache
docker push garystafford/kafka-demo-service:1.1.0-scram
```

### Check Logs from Consumer

```shell
export KAFKA_CONTAINER=$(kubectl get pods -n kafka -l app=kafka-demo-go | awk 'FNR == 2 {print $1}')
kubectl logs $KAFKA_CONTAINER -n kafka
```