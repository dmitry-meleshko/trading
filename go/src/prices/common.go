package prices

import (
	"fmt"
	"os"
)

// file locations
const (
	InDirFmt  = "C:\\Users\\%s\\Desktop\\EODData\\in"
	OutDirFmt = "C:\\Users\\%s\\Desktop\\EODData\\processed"
	LogFile   = "eod.log"
)

var (
	// InDir is where EOD ZIP files to be imported are stored
	InDir string
	// OutDir is where processed ZIP files are dumped
	OutDir string
)

// DB specific
const (
	DbUser = "apical_user"
	DbPass = "XghJ4cf%Q3"
	DbName = "apical"
	DbHost = "localhost"
	DbPort = "5432"
)

// EODPrice maps price data as it's presented in EOD zip/csv files
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

// Symbol maps ticker's data as it's tored in a database
type Symbol struct {
	ID         int
	Symbol     string
	YSymbol    string
	Exchange   string
	Optionable bool
	Date       string
}

// PriceDaily maps price data as it's stored in a database
type PriceDaily struct {
	ID     int
	Date   string
	Open   string
	High   string
	Low    string
	Close  string
	Volume string
}

// SymbolPrices holds ticker data along with daily price hitory
type SymbolPrices struct {
	Symbol Symbol
	Prices []PriceDaily
}

func init() {
	InDir = fmt.Sprintf(InDirFmt, os.Getenv("Username"))
	OutDir = fmt.Sprintf(OutDirFmt, os.Getenv("Username"))
}
