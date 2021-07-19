package main

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ssm"
	"strings"
)

var (
	paramName = "/msk/scram/brokers"
)

func getBrokers() []string {
	ssmsvc := ssm.New(sess, aws.NewConfig())

	param, err := ssmsvc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String(paramName),
		WithDecryption: aws.Bool(false),
	})
	if err != nil {
		panic(err)
	}

	return strings.Split(*param.Parameter.Value, ",")
}
