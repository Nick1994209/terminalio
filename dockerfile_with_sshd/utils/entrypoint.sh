#!/bin/bash

echo "Starting entrypoint.sh..."

# Check if SSH host keys exist
echo "Checking SSH host keys..."
if [ -f "/etc/ssh/ssh_host_rsa_key" ]; then
    echo "SSH host RSA key exists"
else
    echo "SSH host RSA key does not exist, generating..."
fi

# Generate SSH host keys only if they don't exist
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
    echo "Generating SSH host keys..."
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
    chmod 600 /etc/ssh/*_key
    chmod 644 /etc/ssh/*.pub
    echo "SSH host keys generated successfully"
else
    echo "SSH host keys already exist"
fi

# Copy public key to authorized_keys
echo "Setting up SSH authorized keys..."
if [ -f "/etc/ssh/.ssh_aicloud/jovyan_keys" ]; then
    cp /etc/ssh/.ssh_aicloud/jovyan_keys /home/jovyan/.ssh/authorized_keys
    chmod 600 /home/jovyan/.ssh/authorized_keys
    chown jovyan:jovyan /home/jovyan/.ssh/authorized_keys
    echo "SSH authorized keys set up successfully"
else
    echo "Warning: SSH public key not found"
fi

# List SSH host keys
echo "Listing SSH host keys:"
ls -la /etc/ssh/ssh_host_*_key

# Start SSH daemon with sudo to ensure proper permissions
echo "Starting SSH daemon..."
sudo /usr/sbin/sshd -D -e &
SSHD_PID=$!
echo "SSH daemon started with PID: $SSHD_PID"

# Wait a moment for SSH daemon to start
sleep 2

# Check if SSH daemon is running
if ps -p $SSHD_PID > /dev/null; then
    echo "SSH daemon is running"
else
    echo "SSH daemon failed to start"
fi

# Start terminalio application
echo "Starting terminalio application..."
sudo -u appuser /app/main