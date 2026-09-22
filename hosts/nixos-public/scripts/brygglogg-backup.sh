#!/bin/sh
set -eu

GHOST_ROOT="/home/emil/projects/brygglogg"
GHOST_FILES="/mnt/brygglogg-data"

RCLONE_BUCKET="brygglogg-backups"
RETAIN_AGE="14d"

export RCLONE_CONFIG_S3_TYPE="s3"
export RCLONE_CONFIG_S3_PROVIDER="AWS"
export RCLONE_CONFIG_S3_REGION="eu-north-1"

TEMP_PATH=$(mktemp -d)
trap 'rm -rf "$TEMP_PATH"' EXIT

TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "📥 Compressing: $GHOST_ROOT"
tar czf "$TEMP_PATH/ghost-root-$TIMESTAMP.tar.gz" "$GHOST_ROOT"

echo "📥 Compressing: $GHOST_FILES"
tar czf "$TEMP_PATH/ghost-files-$TIMESTAMP.tar.gz" "$GHOST_FILES"

echo "⏩ Uploading to s3://$RCLONE_BUCKET"
rclone copy "$TEMP_PATH" "s3:$RCLONE_BUCKET"

echo "🧹 Enforcing retention: deleting backups older than $RETAIN_AGE"
rclone delete --min-age "$RETAIN_AGE" "s3:$RCLONE_BUCKET"

echo "🏁 Backup completed!"
