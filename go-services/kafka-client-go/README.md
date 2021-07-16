# Kafka Client Producer/Consumer Combination Demo App

## Test in Kubernetes Container without Compiling

### Code References

- <https://www.sohamkamani.com/golang/working-with-kafka/>
- <https://github.com/sohamkamani/golang-kafka-example/>
- <https://github.com/segmentio/kafka-go>

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

### Sample Output from Consumer

![Consumer](consumer.png)
