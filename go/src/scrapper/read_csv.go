package main

import (
	"bufio"
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"time"
)

const IN_CSV_FMT string = "C:\\Users\\%s\\Desktop\\EODData\\views\\SummaryView.csv"

type Ticker struct {
	Symbol string
	Date   string
}

func main() {
	var IN_CSV = fmt.Sprintf(IN_CSV_FMT, os.Getenv("Username"))
	fmt.Println("Opening " + IN_CSV)
	csvFile, _ := os.Open(IN_CSV)
	reader := csv.NewReader(bufio.NewReader(csvFile))
	var ticker []Ticker
	// skip header
	if _, err := reader.Read(); err != nil {
		log.Fatalln(err)
	}

	for {
		line, err := reader.Read()
		if err == io.EOF {
			break
		} else if err != nil {
			log.Fatalln(err)
		}

		ticker = append(ticker, Ticker{
			Symbol: line[0],
			Date:   line[2],
		})
	}
	//fmt.Printf("%+v\n", ticker[0])

	Scrape(ticker[0].Symbol, ticker[0].Date, time.Now().Format("02-Jan-2006"))

}
