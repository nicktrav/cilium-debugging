package main

import (
	"context"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/metric/prometheus"
	"go.opentelemetry.io/otel/metric"
)

func main() {
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}

	meter := otel.Meter("cloudnatix.com/backend")
	echoRequests := metric.Must(meter).NewInt64Counter("echo.requests")
	aRequests := metric.Must(meter).NewInt64Counter("a.requests")
	bRequests := metric.Must(meter).NewInt64Counter("b.requests")

	ctx := context.Background()
	http.HandleFunc("/echo", func(writer http.ResponseWriter, request *http.Request) {
		log.Printf("handling /echo request")
		echoRequests.Add(ctx, 1)
		b, err := ioutil.ReadAll(request.Body)
		if err != nil {
			log.Printf("read: %s", err)
			write(writer, fmt.Sprintf("uh oh: %s", err))
			writer.WriteHeader(http.StatusInternalServerError)
		}
		write(writer, fmt.Sprintf("Echo: %q (host=%s)", string(b), hostname))
	})

	http.HandleFunc("/a", func(writer http.ResponseWriter, request *http.Request) {
		aRequests.Add(ctx, 1)
		log.Printf("handling /a request")
		write(writer, fmt.Sprintf("Hello from endpoint /a (host=%s)", hostname))
	})

	http.HandleFunc("/b", func(writer http.ResponseWriter, request *http.Request) {
		bRequests.Add(ctx, 1)
		log.Printf("handling /b request")
		write(writer, fmt.Sprintf("Hello from endpoint /b (host=%s)", hostname))
	})

	exp, err := prometheus.InstallNewPipeline(prometheus.Config{})
	if err != nil {
		log.Fatalf("failed to initialize metrics exporter: %s", err)
	}
	http.HandleFunc("/metrics", exp.ServeHTTP)

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
