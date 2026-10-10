FROM golang:1.25-alpine AS build

RUN apk add --no-cache git
RUN go install github.com/vishen/go-chromecast@latest

FROM alpine:3.22

RUN apk add --no-cache ca-certificates
COPY --from=build /go/bin/go-chromecast /usr/local/bin/go-chromecast

EXPOSE 8011
ENTRYPOINT ["go-chromecast", "httpserver"]
CMD ["--http-addr", "0.0.0.0", "--http-port", "8011"]
