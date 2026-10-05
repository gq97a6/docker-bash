#!/bin/bash
set -e

ACTION="$1"
VOLUME_NAME="$2"
TARGET="$3"

usage() {
  echo "Usage:" >&2
  echo "  $0 backup  <volume_name> [backup_dir]" >&2
  echo "  $0 restore <volume_name> <path/to/backup.tar.gz>" >&2
  exit 1
}

[ -z "$ACTION" ] || [ -z "$VOLUME_NAME" ] && usage

case "$ACTION" in
  backup)
    BACKUP_DIR="${TARGET:-$(pwd)}"

    if ! docker volume inspect "$VOLUME_NAME" > /dev/null 2>&1; then
      echo "Error: Volume '$VOLUME_NAME' does not exist." >&2
      exit 1
    fi

    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="${VOLUME_NAME}_$(date +%Y%m%d_%H%M%S).tar.gz"

    echo "Backing up '$VOLUME_NAME' to '$BACKUP_DIR/$BACKUP_FILE'..."
    docker run --rm \
      -v "$VOLUME_NAME":/data \
      -v "$BACKUP_DIR":/backup \
      alpine tar czf "/backup/$BACKUP_FILE" -C /data .
    echo "Done."
    ;;

  restore)
    BACKUP_FILE="$TARGET"

    if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
      echo "Error: Backup file '$BACKUP_FILE' not found." >&2
      exit 1
    fi

    # Create volume if it doesn't exist
    docker volume create "$VOLUME_NAME" > /dev/null

    # Absolute path for mounting
    FILE_DIR="$(cd "$(dirname "$BACKUP_FILE")" && pwd)"
    FILE_NAME="$(basename "$BACKUP_FILE")"

    echo "Restoring '$FILE_NAME' into '$VOLUME_NAME'..."
    docker run --rm \
      -v "$VOLUME_NAME":/data \
      -v "$FILE_DIR":/backup \
      alpine tar xzf "/backup/$FILE_NAME" -C /data
    echo "Done."
    ;;

  *)
    usage
    ;;
esac
