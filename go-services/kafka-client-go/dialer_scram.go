package main

import (
	"encoding/json"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
	"github.com/segmentio/kafka-go"
	"github.com/segmentio/kafka-go/sasl/scram"
	"time"
)

var (
	region       = "us-east-1"
	secretId     = "AmazonMSK_credentials"
	versionStage = "AWSCURRENT"
)

func getCredentials() (string, string, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	svc := secretsmanager.New(sess)
	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String(secretId),
		VersionStage: aws.String(versionStage),
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case secretsmanager.ErrCodeResourceNotFoundException:
				log.Error(secretsmanager.ErrCodeResourceNotFoundException, aerr.Error())
			case secretsmanager.ErrCodeInvalidParameterException:
				log.Error(secretsmanager.ErrCodeInvalidParameterException, aerr.Error())
			case secretsmanager.ErrCodeInvalidRequestException:
				log.Error(secretsmanager.ErrCodeInvalidRequestException, aerr.Error())
			case secretsmanager.ErrCodeDecryptionFailure:
				log.Error(secretsmanager.ErrCodeDecryptionFailure, aerr.Error())
			case secretsmanager.ErrCodeInternalServiceError:
				log.Error(secretsmanager.ErrCodeInternalServiceError, aerr.Error())
			default:
				log.Error(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			log.Error(err.Error())
		}
	}

	kmsCredentials := map[string]string{}
	if err := json.Unmarshal([]byte(*result.SecretString), &kmsCredentials); err != nil {
		return "", "", err
	}

	return kmsCredentials["username"], kmsCredentials["password"], nil
}

func saslScramDialer() *kafka.Dialer {
	username, password, err := getCredentials()
	if err != nil {
		log.Fatal(err)
	}

	mechanism, err := scram.Mechanism(scram.SHA512, username, password)
	if err != nil {
		log.Fatal(err)
	}

	config := tlsConfig()
	dialer := &kafka.Dialer{
		Timeout:       10 * time.Second,
		DualStack:     true,
		TLS:           config,
		SASLMechanism: mechanism,
	}

	return dialer
}
