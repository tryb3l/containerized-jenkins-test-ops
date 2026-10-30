#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="jenkins-nginx/certs"
CRT_FILE="${CERT_DIR}/localhost.crt"
KEY_FILE="${CERT_DIR}/localhost.key"

mkdir -p "$CERT_DIR"

if [[ -s "$CRT_FILE" && -s "$KEY_FILE" ]]; then
  exit 0
fi

if command -v mkcert >/dev/null 2>&1; then
  echo "Generating locally trusted HTTPS certificate via mkcert..."
  mkcert -install >/dev/null 2>&1 || true
  mkcert -cert-file "$CRT_FILE" -key-file "$KEY_FILE" localhost 127.0.0.1 ::1
else
  echo "Generating self-signed HTTPS certificate via openssl..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CRT_FILE" \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1,IP:::1" >/dev/null 2>&1
fi

chmod 644 "$CRT_FILE"
chmod 600 "$KEY_FILE"

