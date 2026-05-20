#!/bin/bash
set -e

# Define directories and file paths
CERT_DIR="./certs"
KEY_FILE="${CERT_DIR}/key.pem"
CERT_FILE="${CERT_DIR}/cert.pem"

# Create the certs directory if it doesn't exist
mkdir -p "${CERT_DIR}"

echo "Generating a new 2048-bit RSA private key..."
openssl genrsa -out "${KEY_FILE}" 2048

echo "Generating a self-signed X.509 certificate valid for 10 years (3650 days)..."
# We use -subj to automatically provide the Subject information and avoid interactive prompts.
# The CN (Common Name) is set to windowsupdate.microsoft.com to match the client's SNI spoofing.
openssl req -new -x509 -key "${KEY_FILE}" -out "${CERT_FILE}" -days 3650 -subj "/C=US/ST=WA/L=Redmond/O=Microsoft Corporation/CN=windowsupdate.microsoft.com"

echo "Certificate generation complete."
echo "Key saved to: ${KEY_FILE}"
echo "Certificate saved to: ${CERT_FILE}"

# Secure the private key
chmod 600 "${KEY_FILE}"
