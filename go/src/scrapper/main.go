package main

import (
	"bufio"
	"encoding/csv"
	"flag"
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

type ScrapeResult struct {
	Ticker  Ticker
	History []TickerHistory
	Err     error
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

	// Yahoo provides history up-to yesterday
	endDate := time.Now().Add(-24 * time.Hour).Format("02-Jan-2006")

	endDatePtr := flag.String("end", endDate, "End Date in DD-MMM-YYYY (02-Jan-2006) format")
	flag.Parse()

	if _, err := time.Parse("02-Jan-2006", *endDatePtr); err == nil {
		endDate = *endDatePtr
	}
	resultChan := make(chan ScrapeResult)

	// prepare to collect results fro mscrapping
	go writeResults(OUT_CSV_DIR, endDate, resultChan)

	// scrape all tickers

	for i := range tickers {
		//for i := 0; i < 5; i++ {
		if tickers[i].Date == endDate {
			continue // history is up to date
		}

		// scrape historical price for ticker since the last date until now
		go Scrape(tickers[i], endDate, resultChan)

		// rate limit scrapping
		<-time.Tick(1000 * time.Millisecond)
	}

	close(resultChan)
}

func writeResults(OUT_CSV_DIR string, endDateStr string, resultChan <-chan ScrapeResult) {
	// record failures, if any, to timestamped errors file
	FAIL_CSV := fmt.Sprintf("%s\\errors_%s.csv", OUT_CSV_DIR, time.Now().Format("20060102150405"))

	failFile, err := os.Create(FAIL_CSV)
	if err != nil {
		log.Fatalln(err)
	}
	defer failFile.Close()

	failWriter := csv.NewWriter(failFile)
	defer failWriter.Flush()
	failWriter.Write([]string{"Symbol", "Exchange", "StartDate", "EndDate", "Error"})

	for {
		r, ok := <-resultChan
		if ok == false {
			break
		}
		if r.Err != nil {
			failWriter.Write(
				[]string{r.Ticker.Symbol, r.Ticker.Exchange, r.Ticker.Date, endDateStr, r.Err.Error()})
			failWriter.Flush()
			log.Printf("Failed to scrape %s: %s", r.Ticker.Symbol, r.Err.Error())
		} else {
			// write historical price for future processing by MATLAB
			OUT_CSV := fmt.Sprintf("%s\\%s_%s.csv", OUT_CSV_DIR, r.Ticker.Exchange, r.Ticker.Symbol)
			writeCSV(OUT_CSV, r.History)
		}
	}

	return
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
