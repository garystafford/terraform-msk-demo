# Instructions

```shell
# build
time docker build -t garystafford/kafka-client-msk:1.0.2 . --no-cache

# push
docker push garystafford/kafka-client-msk:1.0.2

# test
docker run -it --rm garystafford/kafka-client-msk:1.0.2
```
