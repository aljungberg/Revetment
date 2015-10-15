#!/bin/bash

set -e

export SSHFS_MOUNT=/mnt/backup
export REPOSITORY="$SSHFS_MOUNT"/"$BACKUP_NAME"
export BACKUP_ROOT="/b/"

export PATH=$PATH:/usr/local/bin

not_mounted() {
  if mount | grep "$1" >/dev/null; then
      return 1
  else
      return 0
  fi
}

if [[ ! -r "/root/.attic" ]]; then
  echo "Add /root/.attic as a volume for encryption keys."
  exit 1
fi

if [[ ! -w "/root/.cache" ]]; then
  echo "Warning: for performance reasons it's recommended to add /root/.cache as a writable volume for the attic cache."
  mkdir -p /root/.cache
fi

# Bring in SSH keys from Docker volume.
cp /known_hosts /root/.ssh/
cp /id_rsa /root/.ssh/
chown -R root:root /root/.ssh
chmod -R u=rwX,g=,o= /root/.ssh

if not_mounted "$SSHFS_MOUNT"; then
  echo "Mounting backup server..."
  mkdir -p "$SSHFS_MOUNT"
  sshfs -o auto_cache,reconnect "$SSH_PATH" "$SSHFS_MOUNT"
fi

cd "$BACKUP_ROOT"

if [[ "$1" == "init" ]]; then
    if [[ ! -w "/root/.attic" ]]; then
      echo "/root/.attic needs to be read-write during init."
      exit 1
    fi

    echo "Creating repository..."
    printf "\n\n" | attic init --encryption=keyfile "$REPOSITORY"
elif [[ ! -e "$REPOSITORY" ]]; then
    echo "No repository found. Did you run 'init'?"
    exit 1
else
    echo "Backing up..."
    backup.py $@

    if [[ "$1" == "create" ]]; then
        attic prune -v "$REPOSITORY" -d $KEEP_DAILY
    fi
fi

fusermount -u "$SSHFS_MOUNT"
