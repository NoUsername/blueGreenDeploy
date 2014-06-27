package main

import "flag"
import "fmt"
import "net/http"

var port = 8081
var serverMessage string

func init() {
	flag.StringVar(&serverMessage, "message", "server 1", "server default message")
	flag.IntVar(&port, "port", 8081, "server listening port")
}

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<html><body>Hello from %v</body></html>", serverMessage)
}

func main() {
	flag.Parse()
	fmt.Println("Starting")
	listenOn := fmt.Sprintf(":%d", port)
	fmt.Println(listenOn)
	fmt.Println("message is ", serverMessage)
	http.HandleFunc("/", handler)
	http.ListenAndServe(listenOn, nil)
}
