FROM golang:1.15.5 AS build

RUN go get -u github.com/tsenart/vegeta

FROM debian:buster-slim

RUN apt-get update && apt-get install -y curl

COPY --from=build /go/bin/vegeta /usr/local/bin/

ENTRYPOINT ["vegeta"]
