package eod

import (
	"fmt"
	"os"
)

// file locations
const (
	IN_DIR_FMT  = "C:\\Users\\%s\\Desktop\\EODData\\in"
	OUT_DIR_FMT = "C:\\Users\\%s\\Desktop\\EODData\\processed"
	LOG_FILE    = "eod.log"
)

var (
	IN_DIR  string
	OUT_DIR string
)

// DB specific
const (
	DB_USER = "apical_user"
	DB_PASS = "XghJ4cf%Q3"
	DB_NAME = "apical"
	DB_HOST = "localhost"
	DB_PORT = "5432"
)

type EODPrice struct {
	Symbol   string
	Exchange string
	Date     string
	Open     string
	High     string
	Low      string
	Close    string
	Volume   string
}

type Symbol struct {
	Id         int
	Symbol     string
	YSymbol    string
	Exchange   string
	Optionable bool
	Date       string
}

type PriceDaily struct {
	Id     int
	Date   string
	Open   string
	High   string
	Low    string
	Close  string
	Volume string
}

type SymbolPrices struct {
	Symbol Symbol
	Prices []PriceDaily
}

func init() {
	IN_DIR = fmt.Sprintf(IN_DIR_FMT, os.Getenv("Username"))
	OUT_DIR = fmt.Sprintf(OUT_DIR_FMT, os.Getenv("Username"))
}
