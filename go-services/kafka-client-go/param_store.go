package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ssm"
	"strings"
)

func getBrokers() []string {
	sess := createSession()
	ssmsvc := ssm.New(sess, aws.NewConfig())

	param, err := ssmsvc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String("/msk/scram/brokers"),
		WithDecryption: aws.Bool(false),
	})
	if err != nil {
		panic(err)
	}

	brokersParam := strings.Split(*param.Parameter.Value, ",")

	brokers = append(brokers, brokersParam[0])

	if len(brokersParam) == 2 {
		brokers = append(brokers, brokersParam[1])
	}
	if len(brokersParam) == 3 {
		brokers = append(brokers, brokersParam[2])
	}

	return brokers
}
