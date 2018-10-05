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
const OUT_CSV_DIR_FMT string = "C:\\Users\\%s\\Desktop\\EODData\\quotes\\yhoo"

type Ticker struct {
	Symbol   string
	Exchange string
	Date     string
}

type TickerHistory struct {
	Date   string
	Open   string
	High   string
	Low    string
	Close  string
	Volume string
}

func main() {
	tickers := readCSV()
	//fmt.Printf("%+v\n", ticker[0])

	for i := range tickers {
		history := Scrape(tickers[i].Symbol, tickers[i].Date, time.Now().Format("02-Jan-2006"))
		writeCSV(tickers[i], history)
	}
}

func readCSV() []Ticker {
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
			Symbol:   line[0],
			Exchange: line[1],
			Date:     line[2],
		})
	}

	return ticker
}

func writeCSV(ticker Ticker, history []TickerHistory) {

}
