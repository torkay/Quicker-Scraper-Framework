FROM crystallang/crystal:1.19.1-alpine AS builder

WORKDIR /app

COPY shard.yml shard.lock ./
RUN shards install --production

COPY . .
RUN crystal build src/main.cr -o bin/scraper --release --static --no-debug

FROM alpine:3.21

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/bin/scraper /usr/local/bin/scraper
COPY --from=builder /app/config /etc/scraper/config

ENTRYPOINT ["scraper"]
CMD ["--help"]
