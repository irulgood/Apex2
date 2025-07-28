#!/bin/bash

REPO="https://raw.githubusercontent.com/irulgood/Apex2/ZX"

echo "🔧 Downloading limit-ip.sh..."
wget -q -O /etc/xray/limit-ip "${REPO}/limit-ip" || {
  echo "❌ Gagal download limit-ip.sh"
  exit 1
}
chmod +x /etc/xray/limit-ip

echo "📦 Membuat systemd service..."

cat > /etc/systemd/system/limitip.service << 'EOF'
[Unit]
Description=Limit All Xray Multi Login IP
After=network.target

[Service]
ExecStart=/etc/xray/limit-ip.sh
Restart=on-failure
User=root
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd..."
systemctl daemon-reload

echo "🚀 Enabling and starting limitip service..."
systemctl enable --now limitip

echo "✅ Installasi selesai. Cek dengan: systemctl status limitip"