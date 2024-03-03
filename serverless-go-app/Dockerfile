
FROM golang:1.16-alpine
WORKDIR /app
COPY . .
RUN go build .
EXPOSE 80
CMD ["./serverless-go-app"]
