package main

import (
	"eod"
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	fmt.Println("Started main()")

	logFile, err := os.OpenFile(eod.LOG_FILE, os.O_CREATE|os.O_APPEND, 0644)
	if err != nil {
		log.Fatal(err)
	}
	defer logFile.Close()
	w := io.MultiWriter(os.Stderr, logFile)
	log.SetOutput(w)

	// set up data channel
	chPrice := make(chan eod.EODPrice, 100)
	chDone := make(chan bool)

	// start background worker for data processing
	go eod.StorageSink(chPrice)

	// kick off Zip files processing
	go eod.ProcessZips(chPrice, chDone)

	<-chDone

	fmt.Println("Finished main()")
}
