package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
)

var (
	sess     = &session.Session{}
	region       = "us-east-1"
)

func main() {
	sess = createAwsSession()
	getParameters()
	getSecrets()
}

func createAwsSession() *session.Session {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		fmt.Println(err.Error())
	}

	return sess
}
