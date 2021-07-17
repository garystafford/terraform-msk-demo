package main

import (
	"github.com/segmentio/kafka-go"
	"time"
)

func plainDialer() *kafka.Dialer {
	config := tlsConfig()
	dialer := &kafka.Dialer{
		Timeout:   10 * time.Second,
		DualStack: true,
		TLS:       config,
	}

	return dialer
}
