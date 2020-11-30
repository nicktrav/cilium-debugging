package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}

	http.HandleFunc("/echo", func(writer http.ResponseWriter, request *http.Request) {
		log.Printf("handling /echo request")
		b, err := ioutil.ReadAll(request.Body)
		if err != nil {
			log.Printf("read: %s", err)
			write(writer, fmt.Sprintf("uh oh: %s", err))
			writer.WriteHeader(http.StatusInternalServerError)
		}
		write(writer, fmt.Sprintf("Echo: %q (host=%s)", string(b), hostname))
	})

	http.HandleFunc("/a", func(writer http.ResponseWriter, request *http.Request) {
		log.Printf("handling /a request")
		write(writer, fmt.Sprintf("Hello from endpoint /a (host=%s)", hostname))
	})

	http.HandleFunc("/b", func(writer http.ResponseWriter, request *http.Request) {
		log.Printf("handling /b request")
		write(writer, fmt.Sprintf("Hello from endpoint /b (host=%s)", hostname))
	})

	log.Printf("Starting server")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}

func write(w io.Writer, s string) {
	if _, err := io.WriteString(w, s+"\n"); err != nil {
		log.Printf("could not write response: %s", err)
	}
}
