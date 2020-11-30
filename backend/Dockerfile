FROM golang:1.15.5 AS build

WORKDIR /build

COPY . /build

RUN CGO_ENABLED=0 go build -o backend .

FROM debian:buster-slim

COPY --from=build /build/backend /usr/local/bin/

ENTRYPOINT ["backend"]
