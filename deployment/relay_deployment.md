# Private Relay Server Deployment Guide

This guide will walk you through deploying the private RustDesk relay stack on a Linux machine or cloud VPS. The stack includes the RustDesk Rendezvous Server (`hbbs`), the Relay Server (`hbbr`), and an NGINX proxy that intercepts TLS traffic over port 443.

## Prerequisites
1. A Linux machine (Ubuntu/Debian recommended) or cloud VPS.
2. Root or `sudo` privileges.
3. [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/) installed.

## Step 1: Transfer Deployment Files
Copy the `deployment` folder from your local machine to your server.

```bash
# Example using scp (run from your local machine)
scp -r ./deployment user@<your-server-ip>:/home/user/rustdesk-relay
```

## Step 2: Generate Certificates
Log into your server and navigate to the deployment directory. You need to generate the self-signed certificates that NGINX will use to present the spoofed SNI.

```bash
cd /home/user/rustdesk-relay

# Make the generation script executable
chmod +x generate_certs.sh

# Run the script to create the 10-year cert in the ./certs/ directory
./generate_certs.sh
```

*Note: You should see "Key saved to: ./certs/key.pem" and "Certificate saved to: ./certs/cert.pem" upon success.*

## Step 3: Configure the Relay Host
Open the `docker-compose.yml` file in a text editor (like `nano` or `vim`).

```bash
nano docker-compose.yml
```

Locate the `hbbs` command line:
```yaml
command: hbbs -r <RELAY_HOST>
```
Replace `<RELAY_HOST>` with the **public IP address** or **LAN IP address** of this server. (Do not include a port, just the IP). This tells the client where the `hbbr` relay server is located when it registers.

Save and exit the file.

## Step 4: Start the Stack
Start the Docker Compose stack in detached mode:

```bash
docker compose up -d
```

## Step 5: Verify the Deployment
Verify that all three containers (`hbbs`, `hbbr`, `nginx-relay`) are running successfully.

```bash
# Check container status
docker ps

# Check the NGINX logs to ensure it started without certificate errors
docker logs nginx-relay

# Verify that the server is actively listening on port 443
sudo netstat -tulnp | grep 443
```

You are now ready to connect using your customized RustDesk client! All traffic will route securely through port 443 to this server.
