#!/bin/bash
set -e

#VOLUME_NAME=my_volume
#BACKUP_DIR=/path/to/backups

# Load .env file if it exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Validate required variables
: "${VOLUME_NAME:?VOLUME_NAME must be set}"
: "${BACKUP_DIR:=$(pwd)}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${VOLUME_NAME}_${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "Backing up ${VOLUME_NAME}..."
docker run --rm \
  -v "${VOLUME_NAME}":/data \
  -v "${BACKUP_DIR}":/backup \
  alpine tar czf "/backup/${BACKUP_FILE}" -C /data .

echo "Done: ${BACKUP_DIR}/${BACKUP_FILE}"
