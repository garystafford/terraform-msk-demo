package main

import (
	"context"
	"fmt"
	"github.com/segmentio/kafka-go"
)

func consume(ctx context.Context) {
	dialer := saslScramDialer()
	//dialer := plainDialer()

	// initialize a new reader with the brokers and topic
	// the groupID identifies the consumer and prevents
	// it from receiving duplicate messages
	r := kafka.NewReader(kafka.ReaderConfig{
		Brokers: brokers,
		Topic:   topic2,
		GroupID: group,
		Logger:  kafka.LoggerFunc(log.Debugf),
		Dialer:  dialer,
	})
	for {
		// the `ReadMessage` method blocks until we receive the next event
		msg, err := r.ReadMessage(ctx)
		if err != nil {
			panic("could not read message " + err.Error())
		}
		// after receiving the message, log its value
		fmt.Println("received: ", string(msg.Value))
	}
}
