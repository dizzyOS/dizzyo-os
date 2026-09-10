#!/bin/bash
#
# DizzyoOS Simple ISO Creator
# Works in Docker/GitHub Actions containers
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="${SCRIPT_DIR}/archiso"
WORK_DIR="/tmp/dizzyo-work"
OUT_DIR="${SCRIPT_DIR}/output"

echo "========================================"
echo "    DizzyoOS ISO Builder"
echo "========================================"
echo ""

# Clean previous build
echo "[1/5] Cleaning previous build..."
rm -rf "${WORK_DIR}" "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

# Check if mkarchiso exists
if ! command -v mkarchiso &> /dev/null; then
    echo "[ERROR] mkarchiso not found!"
    echo "Install with: pacman -S archiso"
    exit 1
fi

# Check if archiso directory exists
if [[ ! -d "${ISO_DIR}" ]]; then
    echo "[ERROR] archiso directory not found!"
    exit 1
fi

echo "[2/5] Archiso directory found: ${ISO_DIR}"
echo "[3/5] Building ISO with mkarchiso..."

# Run mkarchiso
mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${ISO_DIR}"

echo "[4/5] Build complete!"
echo "[5/5] Output files:"
ls -lh "${OUT_DIR}/"*.iso 2>/dev/null || echo "No ISO found"

echo ""
echo "========================================"
echo "    Build Complete!"
echo "========================================"
echo "ISO location: ${OUT_DIR}/"
