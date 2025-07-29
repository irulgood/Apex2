#!/bin/bash

# backup-clean.sh
# Backup VPS Ubuntu yang efisien (hanya isi aktif) → hasil: .img.gz siap untuk DO
# By ChatGPT x @kamir1673

set -e

echo "🚀 [START] Backup VPS dengan optimalisasi ruang..."

# === VARIABEL ===
DISK="/dev/vda"
PART="/dev/vda1"
DATE=$(date +%Y%m%d)
BASE="ubuntu20-clean-${DATE}"
IMG="${BASE}.img.gz"

# === CEK TOOLS ===
for tool in qemu-img gzip zerofree; do
    if ! command -v $tool &> /dev/null; then
        echo "📦 Menginstal $tool..."
        sudo apt update
        sudo apt install -y ${tool/qemu-img/qemu-utils}
    fi
done

# === STEP: Bersihkan blok kosong (butuh boot dari rescue/live mode) ===
echo "🧼 Membersihkan blok kosong dengan zerofree (butuh partisi unmounted)..."
mountpoint=$(mount | grep "$PART" || true)
if [ -n "$mountpoint" ]; then
    echo "❌ Partisi $PART sedang digunakan. Jalankan script ini dari Rescue Mode / Live CD!"
    exit 1
fi

zerofree $PART

# === STEP: Buat file QCOW2 dari partisi utama saja ===
echo "💾 Membuat QCOW2 dari $PART → ${BASE}.qcow2"
qemu-img convert -f raw -O qcow2 $PART ${BASE}.qcow2

# === STEP: Konversi QCOW2 langsung ke IMG.GZ (hemat storage) ===
echo "📦 Mengkonversi langsung ke IMG.GZ tanpa file .img mentah..."
qemu-img convert -O raw ${BASE}.qcow2 - | gzip -9 > ${IMG}

# === STEP: Upload ke transfer.sh ===
echo "☁️ Mengupload hasil backup ke transfer.sh..."
LINK=$(curl --upload-file ${IMG} https://transfer.sh/${IMG})

# === SELESAI ===
echo ""
echo "✅ Backup selesai!"
echo "📦 File: ${IMG}"
echo "🔗 Link: ${LINK}"
