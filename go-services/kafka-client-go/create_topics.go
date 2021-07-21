package main

import (
	"context"
	"github.com/segmentio/kafka-go"
	"log"
	"net"
	"strconv"
)

func createTopics(topic string, ctx context.Context) {
	partitions := 2
	replication := 2
	dialer := saslScramDialer()
	//dialer := plainDialer()

	conn, err := dialer.DialContext(ctx, "tcp", brokers[0])

	if err != nil {
		panic(err.Error())
	}
	defer func(conn *kafka.Conn) {
		err := conn.Close()
		if err != nil {
			log.Error(err.Error())
		}
	}(conn)

	partitionNames, err := conn.ReadPartitions()
	if err != nil {
		panic(err.Error())
	}

	m := map[string]struct{}{}

	for _, p := range partitionNames {
		m[p.Topic] = struct{}{}
	}
	for k := range m {
		if k == topic {
			return
		}
	}

	controller, err := conn.Controller()
	if err != nil {
		log.Panic(err.Error())
	}
	var controllerConn *kafka.Conn
	controllerConn, err = kafka.Dial("tcp", net.JoinHostPort(controller.Host, strconv.Itoa(controller.Port)))
	if err != nil {
		log.Panic(err.Error())
	}
	defer func(controllerConn *kafka.Conn) {
		err := controllerConn.Close()
		if err != nil {
			log.Error(err.Error())
		}
	}(controllerConn)

	topicConfigs := []kafka.TopicConfig{
		{
			Topic:             topic,
			NumPartitions:     partitions,
			ReplicationFactor: replication,
		},
	}

	err = controllerConn.CreateTopics(topicConfigs...)
	if err != nil {
		log.Panic(err.Error())
	}
}

func createTopicAuto(topic string) {
	ctx2 := context.Background()
	dialer := saslScramDialer()
	//dialer := plainDialer()

	conn, err := dialer.DialLeader(ctx2, "tcp", brokers[0], topic, 0)

	if err != nil {
		panic(err.Error())
	}
	defer func(conn *kafka.Conn) {
		err := conn.Close()
		if err != nil {
			log.Error(err.Error())
		}
	}(conn)

	partitionNames, err := conn.ReadPartitions()
	if err != nil {
		panic(err.Error())
	}

	m := map[string]struct{}{}

	for _, p := range partitionNames {
		m[p.Topic] = struct{}{}
	}
	for k := range m {
		log.Debugf(k)
	}
}
