#!/bin/bash
set -e

# Required env vars:
#   CRD_CODE  — OAuth code from https://remotedesktop.google.com/headless
#   CRD_PIN   — 6-digit PIN you want to use to connect
#   CRD_NAME  — (optional) display name for this machine

NAME="${CRD_NAME:-$(hostname)}"

if [ -z "$CRD_CODE" ] || [ -z "$CRD_PIN" ]; then
    echo "ERROR: CRD_CODE and CRD_PIN environment variables must be set."
    echo "  CRD_CODE  = OAuth code from https://remotedesktop.google.com/headless"
    echo "  CRD_PIN   = 6-digit PIN to use when connecting"
    exit 1
fi

echo "==> Registering Chrome Remote Desktop host as remoteuser..."

# Use expect to handle the PIN prompt non-interactively
sudo -u remoteuser expect <<EOF
spawn /opt/google/chrome-remote-desktop/start-host \
    --code="${CRD_CODE}" \
    --redirect-url="https://remotedesktop.google.com/_/oauthredirect" \
    --name="${NAME}"
expect "Enter a PIN of at least six digits:"
send "${CRD_PIN}\r"
expect "Enter the same PIN again:"
send "${CRD_PIN}\r"
expect eof
EOF

echo "==> Starting Chrome Remote Desktop service..."
sudo -u remoteuser /opt/google/chrome-remote-desktop/chrome-remote-desktop --start

echo ""
echo "✅ Chrome Remote Desktop is running!"
echo "   Connect at: https://remotedesktop.google.com/access"
echo "   Machine name: ${NAME}"
echo ""

# Keep container alive
sleep infinity
