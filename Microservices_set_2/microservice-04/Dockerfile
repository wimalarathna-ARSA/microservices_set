FROM golang:1.20
WORKDIR /app
COPY go.mod ./
RUN go mod download || go mod tidy
COPY . .
RUN go mod tidy && go build -o main .
EXPOSE 3004
CMD ["./main"]
