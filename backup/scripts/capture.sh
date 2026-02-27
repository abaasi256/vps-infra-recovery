#!/bin/bash
# capture.sh - Infrastructure State Capture Engine
# Purpose: Capture volumes, configs, and compose state for disaster recovery.

set -e

BACKUP_DIR="/tmp/infra-backup"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
EXPORT_FILE="infra-export-$TIMESTAMP.tar.gz"

echo "🚀 Starting Infrastructure Capture..."

# Create backup structure
mkdir -p "$BACKUP_DIR/volumes"
mkdir -p "$BACKUP_DIR/configs"

# 1. Capture Docker Compose files
echo "📦 Capturing Compose configurations..."
cp docker-compose*.yml "$BACKUP_DIR/configs/" 2>/dev/null || echo "⚠️ No compose files found in current dir."

# 2. Capture Volumes
echo "💾 Capturing Docker volumes..."
VOLUMES=$(docker volume ls -q)
for vol in $VOLUMES; do
    echo "  - Backing up volume: $vol"
    docker run --rm -v "$vol:/data" -v "$BACKUP_DIR/volumes:/backup" alpine tar czf "/backup/$vol.tar.gz" -C /data .
done

# 3. Generate metadata
echo "📝 Generating metadata..."
cat <<EOF > "$BACKUP_DIR/metadata.json"
{
  "timestamp": "$TIMESTAMP",
  "version": "1.0",
  "captured_by": "anti-gravity-engine",
  "volumes": [$(echo $VOLUMES | sed 's/ /","/g' | sed 's/^/"/' | sed 's/$/"/')]
}
EOF

# 4. Final compression
cd /tmp
tar czf "$EXPORT_FILE" -C "$BACKUP_DIR" .

echo "✅ Capture Complete: /tmp/$EXPORT_FILE"
echo "⚠️ IMPORTANT: Move this file to secure off-site storage."
