// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"io/ioutil"
	"os"
)

// GNU style POSIX standard alternative to flag
// https://godoc.org/github.com/spf13/pflag
// import flag "github.com/spf13/pflag"

// better logger
import "go.uber.org/zap"

var SLogger *zap.SugaredLogger

// NoEnvVar - Missing environment variable error
const NoEnvVar = 2

// FileError - File system error
const FileError = 3

// File path and environement variable for shibboleth private key
const KeyPath = "/etc/shibboleth/sp-key.pem"
const KeyEnvName = "SHIBD_SP_KEY"

// File path and environment variable for shibboleth public cert
const CertPath = "/etc/shibboleth/sp-cert.pem"
const CertEnvName = "SHIBD_SP_CERT"

func InitSugarLogger() {
	logger, _ := zap.NewDevelopment()
	defer logger.Sync() // flushes buffer, if any

	SLogger = logger.Sugar()
}

func getEnv(key string) string {
	value := os.Getenv(key)

	if value == "" {
		SLogger.Error("Environment variable is undef: ", key, "\n\a")
		os.Exit(NoEnvVar)
	}
	return value
}

func writeEnv2File(env string, path string) {

	err := ioutil.WriteFile(path, []byte(getEnv(env)), 0640)

	if err != nil {
		SLogger.Error(err)
		os.Exit(FileError)
	}

	SLogger.Infof("Wrote to file: '%s'. Retrieved from Environment variable: '%s'\n", path, env)
}

func main() {
	InitSugarLogger()

	// now write to public and private key file
	writeEnv2File(KeyEnvName, KeyPath)
	writeEnv2File(CertEnvName, CertPath)
}
