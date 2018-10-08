package main

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
)

const YHIST_TMPL string = "https://finance.yahoo.com/quote/{TICKER}/history?" +
	"period1={START_DATE}&period2={END_DATE}&interval=1d&filter=history&frequency=1d"

func Scrape(ticker Ticker, endDateStr string, resultChan chan<- ScrapeResult) {
	var scrapeRes ScrapeResult
	scrapeRes.Ticker = ticker

	defer func() {
		//fmt.Println(scrapeRes.History)
		resultChan <- scrapeRes
	}()

	tzLoc, _ := time.LoadLocation("Local")
	startDate, err := time.ParseInLocation("02-Jan-2006", ticker.Date, tzLoc) // 2006-01-02 is a template
	if err != nil {
		log.Println(err)
		scrapeRes.Err = err
		return
	}

	endDate, err := time.ParseInLocation("02-Jan-2006", endDateStr, tzLoc)
	if err != nil {
		log.Println(err)
		scrapeRes.Err = err
		return
	}

	priceHist, err := scrapeYhoo(ticker.YSymbol, startDate, endDate)
	if err != nil {
		//log.Println(err)
		scrapeRes.Err = err
		return
	}

	scrapeRes.History = priceHist

	return
}

func scrapeYhoo(ticker string, startDate time.Time, endDate time.Time) ([]TickerHistory, error) {
	// convert template into a URL
	YHIST_URL := strings.Replace(YHIST_TMPL, "{TICKER}", ticker, 1)
	YHIST_URL = strings.Replace(YHIST_URL, "{START_DATE}", fmt.Sprintf("%v", startDate.Unix()), 1)
	YHIST_URL = strings.Replace(YHIST_URL, "{END_DATE}", fmt.Sprintf("%v", endDate.Unix()), 1)
	fmt.Printf("Fetching %s\n", YHIST_URL)

	doc, err := getUrl(YHIST_URL)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	//pageTitle := doc.Find("title").Contents().Text()
	//fmt.Printf("Page Title: '%s\n", pageTitle)

	priceHist, err := parseYPriceTable(doc)
	if err != nil {
		//log.Println(err)
		return nil, err
	}

	// cleanup before returning to caller
	priceClean, err := cleanYPrice(priceHist)
	if err != nil {
		//log.Println(err)
		return nil, err
	}

	return priceClean, nil
}

func parseYPriceTable(doc *goquery.Document) ([][]string, error) {
	// verify headers
	y_headers := []string{"Date", "Open", "High", "Low", "Close*", "Adj Close**", "Volume"}
	var headersMatch bool
	doc.Find("table[data-test='historical-prices'] thead tr:first-child th").EachWithBreak(
		func(i int, item *goquery.Selection) bool {
			td := item.Text()
			//fmt.Printf("%s\t", td)
			if y_headers[i] != td {
				log.Printf("Mismatching Yahoo headers: '%s' != '%s'", y_headers[i], td)
				headersMatch = false
				return false
			}
			headersMatch = true
			return true
		})
	if !headersMatch {
		return nil, fmt.Errorf("Failed to validate Yahoo headers")
	}
	//fmt.Println()

	// pull data into new array
	var priceHist [][]string

	doc.Find("table[data-test='historical-prices'] tbody tr").Each(
		func(i int, item *goquery.Selection) {
			var row []string

			item.Find("td").Each(func(index int, item *goquery.Selection) {
				td := item.Text()
				//fmt.Printf("%s\t", td)
				row = append(row, td)
			})
			//fmt.Println()
			priceHist = append(priceHist, row)
		})

	return priceHist, nil
}

func cleanYPrice(priceHist [][]string) ([]TickerHistory, error) {
	var priceClean []TickerHistory

	for i := range priceHist {
		var row TickerHistory

		date, err := time.Parse("Jan 02, 2006", priceHist[i][0])
		if err != nil {
			continue // skip poorly formatted Date
		}
		row.Date = date.Format("02-Jan-2006")

		// confirm price formatting, skip Close price.
		isPriceClean := true
		for _, j := range []int{1, 2, 3, 5} {
			if _, err := strconv.ParseFloat(priceHist[i][j], 32); err != nil {
				isPriceClean = false
				break
			}
		}
		if !isPriceClean {
			continue // next history record
		}

		row.Open = priceHist[i][1]
		row.High = priceHist[i][2]
		row.Low = priceHist[i][3]
		row.Close = priceHist[i][5] // use Adj.Close instead

		if priceHist[i][6] == "-" {
			priceHist[i][6] = "0" // no trades happened this day
		}

		// remove thousand's separator in Volume
		row.Volume = strings.Replace(priceHist[i][6], ",", "", -1)

		priceClean = append(priceClean, row)
	}

	return priceClean, nil
}

// generic URL fetcher, with custom agent signature
func getUrl(URL string) (*goquery.Document, error) {
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	req, err := http.NewRequest("GET", URL, nil)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "+
		"AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36")

	res, err := client.Do(req)
	if err != nil {
		log.Println(err)
		return nil, err
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		log.Printf("Status code error: %d %s", res.StatusCode, res.Status)
		return nil, fmt.Errorf("Status code error %d for URL %s", res.StatusCode, URL)
	}

	doc, err := goquery.NewDocumentFromResponse(res)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	return doc, nil
}
