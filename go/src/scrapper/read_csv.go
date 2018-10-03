package main

import (
	"Log"
	"bufio"
	"encoding/csv"
	"fmt"
	"io"
	"os"
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
	for {
		line, err := reader.Read()
		if err == io.EOF {
			break
		} else if err != nil {
			log.Fatal(err)
		}

		ticker = append(ticker, Ticker{
			Symbol: line[0],
			Date:   line[1],
		})
	}
	fmt.Printf("%+v\n", ticker)
}
