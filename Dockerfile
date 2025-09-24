# Use Debian as the base image for building
FROM debian:stable-slim AS builder

# Install Go and CA certificates
RUN apt-get update && \
    apt-get install -y \
    golang \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application with optimizations
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o main cmd/main.go

# Base stage with common setup
FROM debian:stable-slim AS base

# Install additional tools
RUN apt-get update && \
    apt-get install -y \
    iputils-ping \
    curl \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create directory for the application
WORKDIR /app

# Create directory for database file
RUN mkdir -p /app/data

# Copy the binary from builder stage
COPY --from=builder /app/main .

# Copy configuration files
COPY --from=builder /app/conf ./conf

# Copy views
COPY --from=builder /app/views ./views

# Copy static
COPY --from=builder /app/static ./static

# Create directory for database file and make it writable
RUN mkdir -p /app/data

# Set environment variable for database path
ENV DB_PATH=/app/data/requests.db

# Expose port
EXPOSE 8080
CMD ["/app/main"]

# Non-root user stage
FROM base AS non-root-user

# Create user and set ownership
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -s /bin/bash -m appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser
# Run the application
CMD ["/app/main"]

# Root user stage
FROM base AS root-user
CMD ["/app/main"]
