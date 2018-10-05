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
	// fetch snapshot view with tickers and last date of available price
	var IN_CSV = fmt.Sprintf(IN_CSV_FMT, os.Getenv("Username"))
	tickers := readCSV(IN_CSV)

	// create output directory
	var OUT_CSV_DIR = fmt.Sprintf(OUT_CSV_DIR_FMT, os.Getenv("Username"))
	if _, err := os.Stat(OUT_CSV_DIR); os.IsNotExist(err) {
		os.Mkdir(OUT_CSV_DIR, os.ModeDir)
	}

	for i := range tickers {
		// scrape historical price for ticker since the last date until now
		history := Scrape(tickers[i].Symbol, tickers[i].Date, time.Now().Format("02-Jan-2006"))

		// write historical price for future processing by MATLAB
		OUT_CSV := fmt.Sprintf("%s\\%s_%s.csv", OUT_CSV_DIR, tickers[i].Exchange, tickers[i].Symbol)
		writeCSV(OUT_CSV, history)
	}
}

func readCSV(IN_CSV string) []Ticker {
	fmt.Println("Opening " + IN_CSV)
	csvFile, err := os.Open(IN_CSV)
	if err != nil {
		log.Fatalln(err)
	}
	defer csvFile.Close()

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

func writeCSV(OUT_CSV string, history []TickerHistory) {
	fmt.Println("Writing to " + OUT_CSV)
	csvFile, err := os.Create(OUT_CSV)
	if err != nil {
		log.Fatalln(err)
	}
	defer csvFile.Close()

	writer := csv.NewWriter(csvFile)
	defer writer.Flush()

	writer.Write([]string{"Date", "Open", "High", "Low", "Close", "Volume"})

	for _, h := range history {
		err := writer.Write([]string{h.Date, h.Open, h.High, h.Low, h.Close, h.Volume})
		if err != nil {
			log.Fatalln(err)
		}
	}

	return
}
