package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/PuerkitoBio/goquery"
)

const YHIST_TMPL string = "https://finance.yahoo.com/quote/TSLA/history?period1=1534824000&period2=1538625600&interval=1d&filter=history&frequency=1d"

func main() {
	scrape()
}

func scrape() {
	YHIST_URL := YHIST_TMPL
	doc := getUrl(YHIST_URL)

	//var metaDescription string
	pageTitle := doc.Find("title").Contents().Text()
	fmt.Printf("Page Title: '%s\n", pageTitle)

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

	fmt.Println(priceHist)
}

func getUrl(YHIST_URL string) *goquery.Document {
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	req, err := http.NewRequest("GET", YHIST_URL, nil)
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
