# Private Relay Server Setup Guide

Deploy your own `hbbs` (rendezvous/ID server) and `hbbr` (relay server) using Docker.

## Prerequisites

- A machine with Docker installed (local Linux box, WSL2, or a free-tier VPS)
- Docker Engine is **free** for personal and small business use
- Ports 21115-21119 accessible from client machines

## Quick Start with Docker Compose

### 1. Create the project directory

```bash
mkdir -p ~/relay-server/data
cd ~/relay-server
```

### 2. Create `docker-compose.yml`

```yaml
version: '3'

services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs -r YOUR_SERVER_IP:21117
    network_mode: host
    volumes:
      - ./data:/root
    restart: unless-stopped
    depends_on:
      - hbbr

  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    network_mode: host
    volumes:
      - ./data:/root
    restart: unless-stopped
```

Replace `YOUR_SERVER_IP` with the public or LAN IP of this machine (e.g., `10.0.50.5`).

### 3. Start the servers

```bash
docker compose up -d
```

### 4. Get the public key

After first start, the server generates a keypair in `./data/`:

```bash
cat ~/relay-server/data/id_ed25519.pub
```

Copy this key — you'll need it for the client configuration.

## Firewall Rules

Open these ports on the host:

| Port  | Protocol | Service |
|-------|----------|---------|
| 21115 | TCP      | hbbs NAT type test |
| 21116 | TCP+UDP  | hbbs rendezvous |
| 21117 | TCP      | hbbr relay |
| 21118 | TCP      | hbbs WebSocket (optional) |
| 21119 | TCP      | hbbr WebSocket (optional) |

### Linux (ufw)

```bash
sudo ufw allow 21115:21119/tcp
sudo ufw allow 21116/udp
```

### Linux (firewalld)

```bash
sudo firewall-cmd --permanent --add-port=21115-21119/tcp
sudo firewall-cmd --permanent --add-port=21116/udp
sudo firewall-cmd --reload
```

## Client Configuration

### Option A: Build-time (recommended for this fork)

Edit `profiles/identity.toml`:

```toml
[network]
relay_ip = "10.0.50.5"     # Your relay server IP
relay_port = 21116          # Rendezvous port (default)
```

Rebuild the client — it will always connect to your private server.

### Option B: Runtime (via UI)

In the client UI, go to **Settings → Network → ID/Relay Server** and set:
- ID Server: `10.0.50.5`
- Relay Server: `10.0.50.5`
- Key: (paste the public key from step 4)

## Verification

On the server:

```bash
docker logs hbbs
docker logs hbbr
```

On the client:

```powershell
netstat -ano | findstr "21116"
```

You should see a connection to your relay IP.

## Free-Tier VPS Options

If you don't want to run the relay on your LAN:

| Provider | Free Tier | Notes |
|----------|-----------|-------|
| Oracle Cloud | 2 AMD VMs, 4 ARM Ampere VMs (always free) | Best free tier |
| Google Cloud | e2-micro (always free) | 1 vCPU, 1 GB RAM |
| AWS | t2.micro (12 months free) | 1 vCPU, 1 GB RAM |

## Notes

- For TLS/WSS on port 443, place an nginx reverse proxy in front of hbbs/hbbr. This is optional for internal LAN use.
- The relay server does NOT see the content of remote desktop sessions — all traffic is end-to-end encrypted with NaCl.
- If you change the server keypair, all clients need to be reconfigured with the new public key.
