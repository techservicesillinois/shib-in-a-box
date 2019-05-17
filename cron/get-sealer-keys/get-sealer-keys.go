// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"sync"
)

import "github.com/robfig/cron"

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

var lock sync.Mutex

var (
	Trace   *log.Logger
	Info    *log.Logger
	Warning *log.Logger
	Error   *log.Logger
)

// Return codes

// UnknownError - Unknown Error
const UnknownError = 127

// NoEnvVar - Environment variable empty or missing
const NoEnvVar = 1

// NoDataSealer - Unable to create the data sealer file
const NoDataSealer = 2

// Init for logging
func InitLoggers(logLevel string) {

	var traceHandle io.Writer = os.Stderr
	var infoHandle io.Writer = os.Stderr
	var warningHandle io.Writer = os.Stderr
	var errorHandle io.Writer = os.Stderr

	switch strings.ToLower(logLevel) {
	case "trace":
		break
	case "error":
		warningHandle = ioutil.Discard
		fallthrough
	case "warning", "warn":
		infoHandle = ioutil.Discard
		fallthrough
	default:
		// default log level is info
		traceHandle = ioutil.Discard
	}

	Trace = log.New(traceHandle,
		"TRACE: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Info = log.New(infoHandle,
		"INFO: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Warning = log.New(warningHandle,
		"WARNING: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Error = log.New(errorHandle,
		"ERROR: ",
		log.Ldate|log.Ltime|log.Lshortfile)
}

// This function is based on code taken from:
// https://docs.aws.amazon.com/sdk-for-go/api/service/secretsmanager/#example_SecretsManager_GetSecretValue_shared00
func getSecret(svc *secretsmanager.SecretsManager, secretID string, versionStage string) (string, error) {

	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String(secretID),
		VersionStage: aws.String(versionStage),
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		Error.Println("Failed to find secret: ", secretID, ", version: ", versionStage)

		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case secretsmanager.ErrCodeResourceNotFoundException:
				Error.Println(secretsmanager.ErrCodeResourceNotFoundException)
			case secretsmanager.ErrCodeInvalidParameterException:
				Error.Println(secretsmanager.ErrCodeInvalidParameterException)
			case secretsmanager.ErrCodeInvalidRequestException:
				Error.Println(secretsmanager.ErrCodeInvalidRequestException)
			case secretsmanager.ErrCodeDecryptionFailure:
				Error.Println(secretsmanager.ErrCodeDecryptionFailure)
			case secretsmanager.ErrCodeInternalServiceError:
				Error.Println(secretsmanager.ErrCodeInternalServiceError)
			}

			Error.Println(aerr.Error())
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			Error.Println(err.Error())
		}
		return "", err
	}

	return *result.SecretString, nil
}

// SprintDataSealer returns a data sealer string
func SprintDataSealer(svc *secretsmanager.SecretsManager, secretID string) (string, error) {
	c := 1
	r := ""

	SprintGetSecret := func(versionStage string) error {
		secret, err := getSecret(svc, secretID, versionStage)

		// For details on data format see:
		// https://wiki.shibboleth.net/confluence/display/SP3/VersionedDataSealer
		if err == nil {
			r += fmt.Sprint(c, ":", secret, "\n")
			c++
		}

		return err
	}

	// Print oldest value first
	SprintGetSecret("AWSPREVIOUS")

	// The final value is the default (i.e. current) key
	err := SprintGetSecret("AWSCURRENT")
	if err != nil {
		return "", err
	}

	return r, nil
}

func getDataSealer(filename string, secretID string) error {
	// I do not know if this code is thread safe so let's serialize
	// it to be sure...
	lock.Lock()
	defer lock.Unlock()

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := secretsmanager.New(sess)

	dataSealer, err := SprintDataSealer(svc, secretID)
	if err != nil {
		return err
	}

	// Open datasealer file and compare to see if the values are same
	oldDataSealer, err := ioutil.ReadFile(filename)

	if err != nil {
		Warning.Println(err)
	} else if string(oldDataSealer) == dataSealer {
		Info.Println("No changes to data sealer.")
		return nil
	}

	err = ioutil.WriteFile(filename, []byte(dataSealer), 0600)

	if err != nil {
		Error.Println(err)
		return err
	}

	Info.Println("Wrote data sealer to file: '", filename, "'.  Retrieved from AWS secret: '", secretID, ".'")
	return err
}

func getEnv(key string) string {
	value := os.Getenv(key)

	if value == "" {
		Error.Println("Environment variable is undef: ", key, "\n\a")
		os.Exit(NoEnvVar)
	}
	return value
}

func main() {
	InitLoggers(os.Getenv("LOG_LEVEL"))

	filename, secretID, schedule := getEnv("KEYS"), getEnv("SECRET_ID"), getEnv("SCHEDULE")

	err := getDataSealer(filename, secretID)
	if err != nil {
		os.Exit(NoDataSealer)
	}

	c := cron.New()
	c.AddFunc(schedule, func() { getDataSealer(filename, secretID) })
	c.Run()

	os.Exit(UnknownError)
}
