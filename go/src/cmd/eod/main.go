package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"prices"
)

func main() {
	fmt.Println("Started main()")

	logFile, err := os.OpenFile(prices.LogFile, os.O_CREATE|os.O_APPEND, 0644)
	if err != nil {
		log.Fatal(err)
	}
	defer logFile.Close()
	w := io.MultiWriter(os.Stderr, logFile)
	log.SetOutput(w)

	// set up data channel
	chPrice := make(chan prices.EODPrice, 100)
	chDone := make(chan bool)

	// start background worker for data processing
	go prices.StorageSink(chPrice)

	// kick off Zip files processing
	go prices.ProcessZips(chPrice, chDone)

	<-chDone

	fmt.Println("Finished main()")
}
