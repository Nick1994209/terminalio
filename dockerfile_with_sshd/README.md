# Terminalio with SSH Access

This directory contains the configuration for running the Terminalio application with SSH access enabled.

## Quick Start

1. Start the container:
   ```bash
   cd dockerfile_with_sshd
   docker-compose up -d
   ```

2. Connect via SSH:
   ```bash
   ssh -i keys/id_rsa -p 2222 jovyan@localhost
   ```

## Detailed Instructions

### Prerequisites

- Docker and Docker Compose installed
- SSH client (usually included with your operating system)

### Starting the Application

1. Navigate to the `dockerfile_with_sshd` directory:
   ```bash
   cd dockerfile_with_sshd
   ```

2. Start the container using Docker Compose:
   ```bash
   docker-compose up -d
   ```

   This will:
   - Build the Docker image (if not already built)
   - Start the container in detached mode
   - Expose the Terminalio web interface on port 8080
   - Expose SSH access on port 2222

### Accessing the Application

#### Web Interface

Access the Terminalio web interface at:
```
http://localhost:8080
```

#### SSH Access

Connect to the container using SSH:

```bash
ssh -i keys/id_rsa -p 2222 jovyan@localhost
```

**Connection Details:**
- **Host:** localhost
- **Port:** 2222
- **Username:** jovyan
- **Private Key:** `keys/id_rsa`

#### SSH Key Authentication

The SSH connection uses public key authentication. The keys are located in the `keys/` directory:

- `keys/id_rsa` - Private key (keep this secure!)
- `keys/id_rsa.pub` - Public key
- `keys/jovyan_keys` - Authorized keys file mounted in the container

### Stopping the Application

To stop the container:
```bash
cd dockerfile_with_sshd
docker-compose down
```

### Troubleshooting

#### SSH Connection Issues

If you encounter permission denied errors:

1. Ensure the container is running:
   ```bash
   docker ps | grep terminalio
   ```

2. Check the container logs:
   ```bash
   cd dockerfile_with_sshd
   docker-compose logs
   ```

3. Verify the SSH daemon is running inside the container:
   ```bash
   docker exec dockerfile_with_sshd-terminalio-ssh-1 ps aux | grep sshd
   ```

#### Key Permissions

Make sure the private key has the correct permissions:
```bash
chmod 600 dockerfile_with_sshd/keys/id_rsa
```

#### Regenerating SSH Keys

If you need to regenerate the SSH keys:

1. Remove the existing keys:
   ```bash
   rm -rf dockerfile_with_sshd/keys/
   ```

2. The keys will be automatically regenerated when you restart the container:
   ```bash
   cd dockerfile_with_sshd
   docker-compose down
   docker-compose up -d
   ```

### Container Configuration

The container is configured with:

- **User:** `jovyan` (non-privileged user with sudo access, automatically unlocked)
- **SSH Port:** 2222 (mapped to host port 2222)
- **Web Port:** 8080 (mapped to host port 8080)
- **Data Persistence:** `./data` directory is mounted to `/app/data`
- **SSH Keys:** `./keys` directory is mounted to `/etc/ssh/.ssh_aicloud`

### Security Notes

- The SSH private key (`keys/id_rsa`) should be kept secure and not shared
- The container uses public key authentication only (no password authentication)
- The `jovyan` user has sudo access for administrative tasks
- The `jovyan` user is automatically unlocked during container creation
- SSH host keys are generated automatically when the container starts

### Customization

To modify the SSH configuration, edit the following files:
- `dockerfile_with_sshd/utils/sshd_config` - SSH daemon configuration
- `dockerfile_with_sshd/utils/entrypoint.sh` - Container startup script
- `dockerfile_with_sshd/docker-compose.yaml` - Docker Compose configuration