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

func Scrape(ticker string, startDateStr string, endDateStr string) []TickerHistory {
	startDate, err := time.Parse("02-Jan-2006", startDateStr) // 2006-01-02 is a template
	if err != nil {
		log.Fatalln(err)
	}

	endDate, err := time.Parse("02-Jan-2006", endDateStr)
	if err != nil {
		log.Fatalln(err)
	}
	priceHist := scrapeYhoo(ticker, startDate, endDate)
	fmt.Println(priceHist)

	return priceHist
}

func scrapeYhoo(ticker string, startDate time.Time, endDate time.Time) []TickerHistory {
	// convert template into a URL
	YHIST_URL := strings.Replace(YHIST_TMPL, "{TICKER}", ticker, 1)
	YHIST_URL = strings.Replace(YHIST_URL, "{START_DATE}", fmt.Sprintf("%v", startDate.Unix()), 1)
	YHIST_URL = strings.Replace(YHIST_URL, "{END_DATE}", fmt.Sprintf("%v", endDate.Unix()), 1)
	fmt.Printf("Fetching %s\n", YHIST_URL)

	doc := getUrl(YHIST_URL)

	//var metaDescription string
	pageTitle := doc.Find("title").Contents().Text()
	fmt.Printf("Page Title: '%s\n", pageTitle)

	priceHist := parseYPriceTable(doc)

	// cleanup before returning to caller
	priceClean := cleanYPrice(priceHist)

	return priceClean
}

func parseYPriceTable(doc *goquery.Document) [][]string {
	// verify headers
	y_headers := []string{"Date", "Open", "High", "Low", "Close*", "Adj Close**", "Volume"}
	doc.Find("table[data-test='historical-prices'] thead tr:first-child th").Each(
		func(i int, item *goquery.Selection) {
			td := item.Text()
			fmt.Printf("%s\t", td)
			if y_headers[i] != td {
				log.Fatalf("Mismatching Yahoo headers: '%s' != '%s'", y_headers[i], td)
			}
		})
	fmt.Println()

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

	return priceHist
}

func cleanYPrice(priceHist [][]string) []TickerHistory {
	var priceClean []TickerHistory

	for i := range priceHist {
		var row TickerHistory

		date, err := time.Parse("Jan 02, 2006", priceHist[i][0])
		if err != nil {
			continue // skip poorly formattd Date
		}
		row.Date = date.Format("02-Jan-2006")
		row.Open = priceHist[i][1]
		row.High = priceHist[i][2]
		row.Low = priceHist[i][3]

		// skip Close, use AdjClose
		if _, err := strconv.ParseFloat(priceHist[i][5], 32); err != nil {
			continue // skip poorly formatted closing price
		}
		row.Close = priceHist[i][5]

		// remove thousand's separator in Volume
		row.Volume = strings.Replace(priceHist[i][6], ",", "", -1)

		priceClean = append(priceClean, row)
	}

	return priceClean
}

// generic URL fetcher, with custom agent signature
func getUrl(URL string) *goquery.Document {
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	req, err := http.NewRequest("GET", URL, nil)
	if err != nil {
		log.Fatalln(err)
	}

	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "+
		"AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36")

	res, err := client.Do(req)
	if err != nil {
		log.Fatalln(err)
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		log.Fatalln("Status code error: %d %s", res.StatusCode, res.Status)
	}

	doc, err := goquery.NewDocumentFromResponse(res)
	if err != nil {
		log.Fatalln(err)
	}

	return doc
}
