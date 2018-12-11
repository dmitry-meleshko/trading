package eod

import (
	"archive/zip"
	"encoding/csv"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func ProcessZips(chPrices chan<- EODPrice, chDone chan<- bool) {
	fmt.Println("Started ProcessZips()")
	files, err := ioutil.ReadDir(IN_DIR)
	if err != nil {
		panic(fmt.Errorf("Failed to read directory %s: %v", IN_DIR, err))
	}

	for _, f := range files {
		if !strings.EqualFold(filepath.Ext(f.Name()), ".zip") {
			continue // skip over non-zip files
		}
		// parse ZIP file and move to Processed directory
		srcName := filepath.FromSlash(IN_DIR + "/" + f.Name())
		destName := filepath.FromSlash(OUT_DIR + "/" + f.Name())
		err := unzipNStore(srcName, chPrices)
		if err != nil {
			log.Printf("Failed to process ZIP file %s: %v", srcName, err)
		}

		err = os.Rename(srcName, destName)
		if err != nil {
			log.Printf("Failed to move ZIP file %s: %v", srcName, err)
		}
		fmt.Println("Processed: " + f.Name() + "\n")
	}

	// shut down the pipeline
	close(chPrices)
	chDone <- true
	close(chDone)
	fmt.Println("Finished ProcessZips()")
	return
}

func unzipNStore(src string, chPrices chan<- EODPrice) error {
	r, err := zip.OpenReader(src)
	if err != nil {
		return err
	}
	defer r.Close()

	// process each CSV file in the archive
	for _, f := range r.File {
		prices, err := parseCSV(f)
		if err != nil {
			log.Printf("Failed to parse CSV file %s: %v", src, err)
		}

		for i := range prices {
			// add processed "prices" data to DB via a channel
			chPrices <- prices[i]
		}
	}

	return nil
}

func parseCSV(f *zip.File) ([]EODPrice, error) {
	var prices []EODPrice

	// i.e. AMEX_1990325.csv
	exchange := strings.SplitN(f.Name, "_", 2)
	if exchange[0] == "" {
		err := errors.New("Failed to extract exchange from " + f.Name + ", skipping.")
		return nil, err
	}

	fopen, err := f.Open()
	if err != nil {
		return nil, err
	}
	r := csv.NewReader(fopen)
	defer fopen.Close()

	r.Read() // skip header
	for {
		line, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Printf("Error while reading file %s: %v", f.Name, err)
		}

		prices = append(prices, EODPrice{
			Symbol:   line[0],
			Exchange: exchange[0],
			Date:     line[1],
			Open:     line[2],
			High:     line[3],
			Low:      line[4],
			Close:    line[5],
			Volume:   line[6],
		})
	}

	return prices, nil
}
