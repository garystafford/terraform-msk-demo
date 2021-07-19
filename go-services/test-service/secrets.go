package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

func getSecrets() {
	svc := secretsmanager.New(sess)
	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String("AmazonMSK_credentials"),
		VersionStage: aws.String("AWSCURRENT"),
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case secretsmanager.ErrCodeResourceNotFoundException:
				fmt.Println(secretsmanager.ErrCodeResourceNotFoundException, aerr.Error())
			case secretsmanager.ErrCodeInvalidParameterException:
				fmt.Println(secretsmanager.ErrCodeInvalidParameterException, aerr.Error())
			case secretsmanager.ErrCodeInvalidRequestException:
				fmt.Println(secretsmanager.ErrCodeInvalidRequestException, aerr.Error())
			case secretsmanager.ErrCodeDecryptionFailure:
				fmt.Println(secretsmanager.ErrCodeDecryptionFailure, aerr.Error())
			case secretsmanager.ErrCodeInternalServiceError:
				fmt.Println(secretsmanager.ErrCodeInternalServiceError, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	//fmt.Println(result)
	//fmt.Println(*result.Name)
	//fmt.Println(*result.ARN)
	//fmt.Println(*result.CreatedDate)
	//fmt.Println(result.SecretBinary)
	//fmt.Println(*result.CreatedDate)
	//fmt.Println(*result.VersionId)
	//fmt.Println(result.VersionStages)
	fmt.Println(*result.SecretString)

	//type credentials struct {
	//	password string
	//	username string
	//}
	//
	//var kmsCredentials credentials
	//if err := json.Unmarshal([]byte(*result.SecretString), &kmsCredentials); err != nil {
	//	log.Fatal(err)
	//}
	//
	//fmt.Println(kmsCredentials)

	kmsCredentials := map[string]string{}
	if err := json.Unmarshal([]byte(*result.SecretString), &kmsCredentials); err != nil {
		fmt.Println(err.Error())
	}

	fmt.Println(kmsCredentials["username"])
	fmt.Println(kmsCredentials["password"])
}

