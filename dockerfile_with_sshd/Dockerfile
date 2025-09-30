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

# Runtime stage with SSH support
FROM ubuntu:22.04

# Install necessary packages including SSH server and terminalio dependencies
RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    zsh \
    sudo \
    iputils-ping \
    curl \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create jovyan user (non-root) and appuser for terminalio
RUN useradd -m -s /bin/zsh -u 1000 jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/bash -m appuser && \
    passwd -d jovyan

# Create SSH directories and set permissions
RUN mkdir -p /run/sshd && \
    mkdir -p /etc/ssh/.ssh_aicloud && \
    mkdir -p /home/jovyan/.ssh && \
    chmod 700 /home/jovyan/.ssh && \
    chown jovyan:jovyan /home/jovyan/.ssh

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

# Copy SSH configuration files
COPY dockerfile_with_sshd/utils/sshd_config /etc/ssh/sshd_config
COPY dockerfile_with_sshd/utils/ssh_config /etc/ssh/ssh_config

# Set proper permissions for SSH config files
RUN chmod 644 /etc/ssh/sshd_config && \
    chmod 644 /etc/ssh/ssh_config && \
    chown root:root /etc/ssh/sshd_config && \
    chown root:root /etc/ssh/ssh_config

# Create directory for environment configuration
RUN mkdir -p /etc/environment.d

# Copy simpler entrypoint script
COPY --chown=jovyan:jovyan dockerfile_with_sshd/utils/entrypoint.sh /home/jovyan/entrypoint.sh
RUN chmod +x /home/jovyan/entrypoint.sh

# Set ownership for app directory
RUN chown -R appuser:appuser /app

# Expose ports
EXPOSE 8080
EXPOSE 2222

# Switch to non-root user for SSH
USER jovyan

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/home/jovyan/entrypoint.sh"]