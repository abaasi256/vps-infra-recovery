#!/bin/bash
# restore.sh - Infrastructure Restoration Engine
# Purpose: Re-provision volumes and services from a capture artifact.

set -e

BACKUP_ARTIFACT=$1

if [ -z "$BACKUP_ARTIFACT" ]; then
    echo "❌ Error: No backup artifact provided."
    echo "Usage: ./restore.sh <path-to-backup.tar.gz>"
    exit 1
fi

echo "🔄 Starting Infrastructure Restoration..."

RESTORE_TMP="/tmp/infra-restore"
mkdir -p "$RESTORE_TMP"

# 1. Unpack artifact
echo "📦 Unpacking artifact..."
tar xzf "$BACKUP_ARTIFACT" -C "$RESTORE_TMP"

# 2. Restore Volumes
echo "💾 Restoring Docker volumes..."
for vol_file in "$RESTORE_TMP/volumes"/*.tar.gz; do
    vol_name=$(basename "$vol_file" .tar.gz)
    echo "  - Restoring volume: $vol_name"
    docker volume create "$vol_name" || true
    docker run --rm -v "$vol_name:/data" -v "$vol_file:/backup.tar.gz" alpine sh -c "tar xzf /backup.tar.gz -C /data"
done

# 3. Restore Configs and Start Services
echo "🚀 Re-deploying services..."
if [ -d "$RESTORE_TMP/configs" ]; then
    cp "$RESTORE_TMP/configs"/* .
    docker compose up -d
fi

echo "✅ Restoration Complete. Services are coming online."
