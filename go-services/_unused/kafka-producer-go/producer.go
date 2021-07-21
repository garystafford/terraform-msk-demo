package main

import (
	"context"
	"fmt"
	"github.com/segmentio/kafka-go"
	"strconv"
	"time"
)

func produce(ctx context.Context) {
	config := tlsConfig()
	dialer := &kafka.Dialer{
		Timeout:   10 * time.Second,
		DualStack: true,
		TLS:       config,
	}

	// initialize the writer with the broker addresses, and the topic
	w := kafka.NewWriter(kafka.WriterConfig{
		Brokers:  brokers,
		Topic:    topic,
		Balancer: &kafka.Hash{},
		Logger:   kafka.LoggerFunc(log.Debugf),
		Dialer:   dialer,
	})

	// initialize a counter
	i := 0

	for {
		// each kafka message has a key and value. The key is used
		// to decide which partition (and consequently, which broker)
		// the message gets published on
		err := w.WriteMessages(ctx, kafka.Message{
			Key: []byte(strconv.Itoa(i)),
			// create an arbitrary message payload for the value
			Value: []byte("this is message " + strconv.Itoa(i)),
		})
		if err != nil {
			panic("could not write message " + err.Error())
		}

		// log a confirmation once the message is written
		fmt.Println("writes: ", i)
		i++
		// sleep for 60 seconds
		time.Sleep(60 * time.Second)
	}
}
