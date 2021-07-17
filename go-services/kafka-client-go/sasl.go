package main

import (
	"github.com/segmentio/kafka-go"
	"github.com/segmentio/kafka-go/sasl/scram"
	"time"
)

func saslScramDialer() *kafka.Dialer {
	mechanism, err := scram.Mechanism(scram.SHA512, "username", "password")
	if err != nil {
		panic(err)
	}

	config := tlsConfig()
	dialer := &kafka.Dialer{
		Timeout:   10 * time.Second,
		DualStack: true,
		TLS:       config,
		SASLMechanism: mechanism,
	}

	return dialer
}
