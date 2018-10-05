package main

import (
	"github.com/PuerkitoBio/goquery"
	"log"
	"net/http"
	"time"
)

func main() {
	client := &http.Client{
		Timeout: 30 * time.Second,
	}

	req, err := http.NewRequest("GET", "http://localhost:8080", nil)
	if err != nil {
		log.Fatalln(err)
	}

	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "+
		"AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36")

	res, err := client.Do(req)
	if err != nil {
		log.Fatalln(err)
	}

	//_, err = goquery.NewDocument("http://localhost:8080")
	_, err = goquery.NewDocumentFromResponse(res)
	if err != nil {
		log.Fatal(err)
	}

}
