package main

import (
	"context"
	lrf "github.com/banzaicloud/logrus-runtime-formatter"
	"github.com/sirupsen/logrus"
	"os"
)

var (
	logLevel       = getEnv("LOG_LEVEL", "debug")
	topic          = getEnv("TOPIC", "demo-events")
	broker1Address = getEnv("BROKER1", "b-1.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094")
	broker2Address = getEnv("BROKER2", "b-2.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094")
	broker3Address = getEnv("BROKER3", "b-3.demo-msk-cluster.tvrqus.c2.kafka.us-east-1.amazonaws.com:9094")
	brokers        = []string{broker1Address, broker2Address, broker3Address}
	log            = logrus.New()
)

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func init() {
	childFormatter := logrus.JSONFormatter{}
	runtimeFormatter := &lrf.Formatter{ChildFormatter: &childFormatter}
	runtimeFormatter.Line = true
	log.Formatter = runtimeFormatter
	log.Out = os.Stdout
	level, err := logrus.ParseLevel(logLevel)
	if err != nil {
		log.Error(err)
	}
	log.Level = level
}

func main() {
	ctx := context.Background()
	produce(ctx)
}
