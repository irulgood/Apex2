#!/bin/bash

# Script: backup-efficient.sh
# Tujuan: Backup VPS dari /dev/vda → qcow2 → img.gz dengan efisiensi storage
# Author: ChatGPT x @kamir1673

set -e

echo "🚀 [START] Backup VPS tanpa habisin storage..."

# === CONFIG ===
DISK="/dev/vda"
DATE=$(date +%Y%m%d)
BASE="ubuntu20-efficient-${DATE}"
QCOW2="${BASE}.qcow2"
FINAL_IMG="${BASE}.img"
FINAL_GZ="${FINAL_IMG}.gz"

# === Cek tool
for tool in qemu-img gzip curl; do
  if ! command -v $tool &> /dev/null; then
    echo "📦 Menginstal $tool..."
    sudo apt update
    sudo apt install -y ${tool/qemu-img/qemu-utils}
  fi
done

# === Step 1: Convert langsung /dev/vda → qcow2
echo "💾 [QCOW2] Convert dari $DISK → $QCOW2"
sudo qemu-img convert -f raw -O qcow2 $DISK $QCOW2

# === Step 2: Convert qcow2 → raw (ringan)
echo "📦 [RAW] Convert QCOW2 → $FINAL_IMG"
qemu-img convert -O raw $QCOW2 $FINAL_IMG

# (Hapus qcow2 kalau mau hemat)
rm -f $QCOW2

# === Step 3: Kompres ke gzip
echo "🗜️ [GZIP] Kompres $FINAL_IMG → $FINAL_GZ"
gzip -9 $FINAL_IMG

# === Step 4: Upload ke transfer.sh
echo "☁️ [UPLOAD] Upload ke transfer.sh..."
LINK=$(curl --upload-file $FINAL_GZ https://transfer.sh/$FINAL_GZ)

# === DONE
echo ""
echo "✅✅✅ Backup Selesai!"
echo "📁 File: $FINAL_GZ"
echo "🔗 Link: $LINK"
