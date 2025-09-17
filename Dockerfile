# Use Debian as the base image
FROM debian:stable-slim

# Install Go, ping, and curl
RUN apt-get update && \
    apt-get install -y \
    golang \
    iputils-ping \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Expose port
EXPOSE 8080

# Build the application
RUN go build -o main .

# Run the application
CMD ["./main"]