package main

import (
	"context"
	lrf "github.com/banzaicloud/logrus-runtime-formatter"
	"github.com/sirupsen/logrus"
	"os"
)

// the topic and broker address are initialized as vars
var (
	logLevel       = getEnv("LOG_LEVEL", "info")
	topic1         = getEnv("TOPIC1", "foo-topic")
	topic2         = getEnv("TOPIC2", "bar-topic")
	group          = getEnv("GROUP", "consumer-group-A")
	broker1Address = getEnv("BROKER1", "localhost:9094")
	broker2Address = getEnv("BROKER2", "")
	broker3Address = getEnv("BROKER3", "")
	brokers        = []string{broker1Address}
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
	log.Debugf("broker1Address: %s", brokers[0])

	if broker2Address != "" {
		brokers = []string{broker1Address, broker2Address}
		log.Debugf("broker2Address: %s", brokers[1])
	}

	if broker3Address != "" {
		brokers = []string{broker1Address, broker2Address, broker3Address}
		log.Debugf("broker3Address: %s", brokers[2])
	}

	// create a new context
	ctx := context.Background()
	// produce messages in a new go routine, since
	// both the produce and consume functions are
	// blocking
	go produce(ctx)
	consume(ctx)
}
