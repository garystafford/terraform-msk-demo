package main

import (
	"context"
	"fmt"
	"github.com/segmentio/kafka-go"
	"strconv"
	"time"
)

func produce(ctx context.Context) {
	dialer := saslScramDialer()
	//dialer := plainDialer()

	// initialize the writer with the broker addresses, and the topic
	w := kafka.NewWriter(kafka.WriterConfig{
		Brokers:  brokers,
		Topic:    topic1,
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
			Value: []byte("this is message: " + strconv.Itoa(i)),
		})
		if err != nil {
			panic("could not write message " + err.Error())
		}

		// log a confirmation once the message is written
		fmt.Println("writes: ", i)
		i++
		// sleep for a second
		time.Sleep(60 * time.Second)
	}
}
