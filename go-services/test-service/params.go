package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ssm"
	"strings"
)

func getParameters() {
	ssmsvc := ssm.New(sess, aws.NewConfig())
	param, err := ssmsvc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String("/msk/scram/brokers"),
		WithDecryption: aws.Bool(false),
	})
	if err != nil {
		panic(err)
	}

	var brokers []string

	brokers = strings.Split(*param.Parameter.Value, ",")

	fmt.Println(brokers)
}

