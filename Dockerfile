# Stage 1: Build JioTV Go
FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git ca-certificates

WORKDIR /app

RUN git clone --depth 1 https://github.com/JioTV-Go/jiotv_go.git .

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-s -w" -o /jiotv_go .

# Stage 2: Runtime
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /jiotv_go /app/jiotv_go

ENV TZ=Asia/Kolkata
ENV JIOTV_DRM=true
ENV JIOTV_PATH_PREFIX=/app/.jiotv_go

EXPOSE 8080

CMD ["/app/jiotv_go", "serve", "--public", "--port", "8080"]
