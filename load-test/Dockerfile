FROM golang:1.15.5 AS build

RUN go get -u github.com/tsenart/vegeta

FROM debian:buster-slim

COPY --from=build /go/bin/vegeta /usr/local/bin/

ENTRYPOINT ["vegeta"]
