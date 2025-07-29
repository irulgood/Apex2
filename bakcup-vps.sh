#!/bin/bash

# Script: backup-vps-auto.sh
# Tujuan: Backup disk VPS, compress, upload, dan kasih link
# Author: ChatGPT x @kamir1673

set -e

echo "🚀 [START] Backup VPS Otomatis dengan Konversi QCOW2 + Upload"

# === CONFIG ===
DISK="/dev/vda"
DATE=$(date +%Y%m%d)
BASENAME="ubuntu20-img-${DATE}"
RAW_ORI="${BASENAME}-raw.img"
QCOW2_TMP="${BASENAME}.qcow2"
RAW_FINAL="${BASENAME}.img"
FINAL_GZ="${RAW_FINAL}.gz"

# === Step 0: Install semua tools kalau belum ada ===
echo "🛠️ [CHECK] Install tool pendukung jika diperlukan..."
REQUIRED_TOOLS=(dd qemu-img gzip curl)

for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v $tool &> /dev/null; then
    echo "📦 Installing missing tool: $tool..."
    sudo apt update
    case $tool in
      qemu-img)
        sudo apt install -y qemu-utils
        ;;
      *)
        sudo apt install -y "$tool"
        ;;
    esac
  else
    echo "✅ $tool sudah terinstall"
  fi
done

# === Step 1: Backup RAW disk ===
echo "📥 [BACKUP] Membuat raw image dari $DISK → $RAW_ORI (ini akan makan waktu)..."
sudo dd if=$DISK of=$RAW_ORI bs=1M status=progress conv=fsync

# === Step 2: Convert ke QCOW2 ===
echo "💾 [CONVERT] Konversi ke QCOW2 → $QCOW2_TMP"
qemu-img convert -f raw -O qcow2 $RAW_ORI $QCOW2_TMP

# === Hapus RAW ORI (hemat ruang)
rm -f $RAW_ORI

# === Step 3: Convert QCOW2 ke RAW kecil
echo "📦 [RECONVERT] QCOW2 → RAW ringan → $RAW_FINAL"
qemu-img convert -O raw $QCOW2_TMP $RAW_FINAL

rm -f $QCOW2_TMP

# === Step 4: Kompres file final
echo "🗜️ [COMPRESS] Mengompresi $RAW_FINAL → $FINAL_GZ"
gzip -9 $RAW_FINAL

# === Step 5: Upload ke transfer.sh
echo "☁️ [UPLOAD] Mengupload ke transfer.sh..."
LINK=$(curl --upload-file ./$FINAL_GZ https://transfer.sh/$FINAL_GZ)

# === DONE ===
echo ""
echo "✅✅✅ Backup VPS SELESAI!"
echo "📁 File image: $FINAL_GZ"
echo "🔗 Link Download Siap Pakai (Custom Image DO):"
echo "$LINK"
