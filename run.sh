#!/bin/bash

set -xe

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
  echo "Add /root/.attic as a volume for encryption keys. On the first run it needs to be read-write."
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
ls -a

if [[ ! -e "$REPOSITORY" ]]; then
  echo "Creating repository..."
  printf "\n\n" | attic init --encryption=keyfile "$REPOSITORY"
fi

backup.py $@

if [[ "$1" == "create" ]]; then
    # Keep a very short history.
    attic prune -v "$REPOSITORY" -d $KEEP_DAILY
fi

fusermount -u "$SSHFS_MOUNT"
