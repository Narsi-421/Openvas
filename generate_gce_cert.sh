#!/bin/bash

# === CONFIGURATION ===
CERT_DIR="$HOME/.ssl"
DEST_DIR="/var/lib/gvm/private/CA"
OWNER_UID=1001      # Replace if needed
COMMON_NAME="your.domain.com"  # Replace with your actual domain or IP

# === STEP 1: Generate Certificate and Key ===
echo "[*] Generating TLS certificate and private key..."
openssl req -x509 -newkey rsa:4096 \
  -keyout serverkey.pem \
  -out servercert.pem \
  -nodes -days 397 \
  -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Greenbone/OU=IT Department/CN=$COMMON_NAME"

# === STEP 2: Move to secure directory ===
echo "[*] Moving files to $CERT_DIR..."
mkdir -p "$CERT_DIR"
mv serverkey.pem servercert.pem "$CERT_DIR"

# === STEP 3: Set ownership and permissions ===
echo "[*] Setting file permissions..."
sudo chown $OWNER_UID:$OWNER_UID "$CERT_DIR/serverkey.pem" "$CERT_DIR/servercert.pem"
sudo chmod 600 "$CERT_DIR/serverkey.pem"
sudo chmod 644 "$CERT_DIR/servercert.pem"

# === STEP 4: Copy into container volume path ===
echo "[*] Copying certificates to $DEST_DIR..."
sudo cp "$CERT_DIR/serverkey.pem" "$DEST_DIR/"
sudo cp "$CERT_DIR/servercert.pem" "$DEST_DIR/"

# === STEP 5: Restart Greenbone containers ===
echo "[*] Restarting Greenbone Community Edition containers..."
docker compose down
docker compose up -d

# === STEP 6: Verification ===
echo "[*] Verifying files inside the container..."
docker exec -it greenbone-community-edition-gsa-1 ls -l "$DEST_DIR"

echo "[✔] Certificate setup complete."
