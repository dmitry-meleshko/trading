package main

import (
	"fmt"
	"net/http"
)

func getUserAgent(w http.ResponseWriter, r *http.Request) {
	ua := r.UserAgent()
	fmt.Printf("User Agent is: %s\n", ua)
	w.Write([]byte("User Agent is " + ua))
}

func main() {
	http.HandleFunc("/", getUserAgent)
	http.ListenAndServe(":8080", nil)
}
