package prices

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq" // blank import as per documentation
)

var (
	db       *sql.DB
	symCache map[string]int
)

/*
StorageSink is an entry point for storing prices in a database
*/
func StorageSink(chPrices <-chan EODPrice) {
	defer db.Close() // connection is open from init()

	db.Prepare("select symbol_id, symbol, exchange, optionable, y_symbol " +
		"from symbol where symbol = ? and exchange = ?")

	fmt.Println("Started StorageSink()")
	for price := range chPrices {
		//log.Println("Data: %v", price)

		// get ID for the ticker
		symID, err := getSymbolIDCache(price.Symbol, price.Exchange)
		if err != nil {
			log.Printf("Failed in getSymbolIDCache(): %v\n", err)
			continue
		}

		pd := &PriceDaily{
			Date:   price.Date,
			Open:   price.Open,
			High:   price.High,
			Low:    price.Low,
			Close:  price.Close,
			Volume: price.Volume,
		}
		if err = addPriceDay(symID, *pd); err != nil {
			log.Printf("Failed to add price for ticker %s/%s to database: %v\n", price.Symbol, price.Exchange, err)
			continue
		}
	}
	fmt.Println("Finished StorageSink()")
}

func init() {
	connStr := fmt.Sprintf("dbname=%s host=%s port=%s user=%s password=%s dbname=%s "+
		"sslmode=disable", DbName, DbHost, DbPort, DbUser, DbPass, DbName)

	var err error // a trick to force global "db" var assignment
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		panic(fmt.Errorf("Failed to open DB connection: %v", err))
	}

	if err := db.Ping(); err != nil {
		db.Close()
		panic(fmt.Errorf("Failed to ping on DB connection: %v", err))
	}

	symCache = make(map[string]int)
}

func getSymbolIDCache(ticker string, exchange string) (int, error) {
	symKey := fmt.Sprintf("%s/%s", ticker, exchange)
	symID := symCache[symKey]

	if symID == 0 { // cache's empty
		sym, err := getSymbol(ticker, exchange)
		if err != nil {
			return -1, fmt.Errorf("Failed to fetch symbol %s/%s: %v", ticker, exchange, err)
		}
		if sym.ID > 0 {
			symCache[symKey] = sym.ID
			symID = sym.ID
		} else {
			// no such ticker exists
			sym := &Symbol{
				Symbol:   ticker,
				Exchange: exchange,
			}
			symID, err = addSymbol(*sym)
			if err != nil {
				return -1, fmt.Errorf("Failed to add symbol %s/%s to database: %v", ticker, exchange, err)
			}
			symCache[symKey] = symID
		}
	}

	return symID, nil
}

func getSymbol(ticker string, exchange string) (*Symbol, error) {
	var s Symbol

	stmt, err := db.Prepare("select symbol_id, symbol, exchange, optionable, y_symbol " +
		"from symbol where symbol = $1 and exchange = $2")
	if err != nil {
		return nil, err
	}
	defer stmt.Close()

	err = stmt.QueryRow(ticker, exchange).Scan(&s.ID, &s.Symbol, &s.Exchange,
		&s.Optionable, &s.YSymbol)
	if err != nil {
		if err != sql.ErrNoRows {
			return nil, err
		}
	}

	return &s, nil
}

func addSymbol(s Symbol) (int, error) {
	var symID int

	stmt, err := db.Prepare("insert into symbol (symbol, exchange, optionable, y_symbol) " +
		"select cast($1 as varchar), cast($2 as varchar), cast($3 as bit), cast($4 as varchar) " +
		" where not exists " +
		"(select symbol_id from symbol where symbol = $1 and exchange = $2) " +
		"on conflict (symbol, exchange) do update " +
		"set optionable=excluded.optionable, y_symbol=excluded.y_symbol " +
		"returning symbol_id")
	if err != nil {
		return -1, err
	}
	defer stmt.Close()

	// cast boolean to int for SQL processing
	option := 0
	if s.Optionable {
		option = 1
	}

	err = stmt.QueryRow(s.Symbol, s.Exchange, option, s.YSymbol).Scan(&symID)
	if err != nil {
		return -1, err
	}

	// TODO: debug this, what's going on with RowsAffected?
	// no records added
	if symID <= 0 {
		log.Printf("Failed to add a new symbol - duplicate record for %s/%s ", s.Symbol, s.Exchange)
		newSym, err := getSymbol(s.Symbol, s.Exchange)
		if err != nil {
			return -1, err
		}
		if newSym.ID > 0 {
			symID = newSym.ID
		}
	}

	return symID, nil
}

func updateSymbol(s Symbol) error {
	stmt, err := db.Prepare("update symbol set optionable = $1, y_symbol = $2 " +
		"where symbol_id = $3")
	if err != nil {
		return err
	}
	defer stmt.Close()

	// cast boolean to int for SQL processing
	option := 0
	if s.Optionable {
		option = 1
	}

	res, err := stmt.Exec(option, s.YSymbol, s.ID)
	if err != nil {
		return err
	}
	rowCnt, err := res.RowsAffected()
	if err != nil {
		return err
	}

	if rowCnt <= 0 {
		return fmt.Errorf("UPDATE for symbol %d (%s/%s) has failed", s.ID, s.Symbol, s.Exchange)
	}

	return nil
}

func getPriceDay(s Symbol, startDate string, endDate string) ([]PriceDaily, error) {
	var prices []PriceDaily

	stmt, err := db.Prepare("select pd.price_ID, pd.day, pd.open, pd.high, pd.low, pd.close, pd.volume " +
		"from price_day pd join symbol s on s.symbol_id = pd.symbol_id " +
		"where s.Symbol = $1 and s.Exchange = $2 and pd.day between $3 and $4")
	if err != nil {
		return nil, err
	}
	defer stmt.Close()

	rows, err := stmt.Query(s.Symbol, s.Exchange, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var p PriceDaily
		err := rows.Scan(&p.ID, &p.Date, &p.Open, &p.High, &p.Low, &p.Close, &p.Volume)
		if err != nil {
			log.Printf("Failed to fetch price record for %s/%s: %v", s.Symbol, s.Exchange, err)
		}
		prices = append(prices, p)
	}
	if err = rows.Err(); err != nil {
		return prices, err
	}

	return prices, nil
}

func addPriceDay(symID int, pd PriceDaily) error {
	stmt, err := db.Prepare("insert into price_day (symbol_id, day, open, high, low, close, volume) " +
		"values ($1, $2, $3, $4, $5, $6, $7) " +
		"on conflict (symbol_id, day) do update set open=excluded.open, high=excluded.high, " +
		"low=excluded.low, close = excluded.close, volume=excluded.volume " +
		"returning price_ID")
	if err != nil {
		return err
	}
	defer stmt.Close()

	//for _, p := range pd {
	err = stmt.QueryRow(symID, pd.Date, pd.Open, pd.High, pd.Low, pd.Close, pd.Volume).Scan(&pd.ID)
	if err != nil {
		return err
	}
	if pd.ID <= 0 {
		log.Printf("Failed to add daily price for symbol ID %d: %v ", symID, pd.Date)
	}
	//}

	return nil
}
