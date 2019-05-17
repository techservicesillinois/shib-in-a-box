// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"io"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"time"
)

var (
	Trace   *log.Logger
	Info    *log.Logger
	Warning *log.Logger
	Error   *log.Logger
)

// Healthy - healthcheck is good
const Healthy = 0

// Unhealthy - Unable to pass the health check
const Unhealthy = 1

// NoDataSealer - Unable to fine the data sealer file
const NoSealerKeyFile = 2

// BadArgs - Too many or bad arguments passed
const BadArgs = 3

// NoEnvVar - Environment variable empty or missing
const NoEnvVar = 1

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

func getEnv(key string) string {
	value := os.Getenv(key)

	if value == "" {
		Error.Println("Environment variable is undef: ", key, "\n\a")
		os.Exit(NoEnvVar)
	}
	return value
}

func isOlderThan(t time.Time, hour time.Duration) bool {
	Trace.Println("age of file is: ", time.Since(t))
	Trace.Println("expected max age: ", hour)

	return time.Since(t) > hour
}

func main() {

	InitLoggers(os.Getenv("LOG_LEVEL"))

	filename := getEnv("KEYS")

	file, err := os.Stat(filename)

	if err != nil {
		Error.Println("Failed to find key file")
		os.Exit(NoSealerKeyFile)
	}

	var keyDuration string = os.Getenv("KEY_DURATION")

	hour, err := time.ParseDuration(keyDuration)

	if err != nil || keyDuration == "" {
		hour = 24 * time.Hour
	}

	if isOlderThan(file.ModTime(), hour) {
		Error.Println("Uh-oh! The file is modified more than", hour, "ago.")
		os.Exit(Unhealthy)
	} else {
		Info.Println("Great! The file is modified less than", hour, "ago.")
		os.Exit(Healthy)
	}
}
