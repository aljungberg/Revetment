#!/bin/bash

SSH_PATH="example.com:test/"
SSH_KNOWN_HOSTS="test/known_hosts"
SSH_ID="test/id_rsa"
BACKUP_ROOT="test/backup/"
ATTIC_KEYS="test/attic"
ATTIC_CACHE="test/cache"
KEEP_DAILY=2
# What to back up. One name per line. Use ./ to back up everything in BACKUP_ROOT.
BACKUP_PATHS="
."
# What to exclude. One exclude per line. Attic style wildcards allowed.
EXCLUDES="
/proc
/dev
/tmp
/var/tmp
/var/log
/var/cache
/media
/lost+found
*ignore.me
"

# http://stackoverflow.com/a/3572105/76900
abspath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

set -xe

BACKUP_MOUNT_FLAGS="ro"

if [[ "$1" == "extract" ]]; then
    BACKUP_ROOT="$3"
    mkdir -p "$BACKUP_ROOT"
    BACKUP_MOUNT_FLAGS="rw"
fi

# -v doesn't handle relative paths.
ATTIC_CACHE=$(abspath "$ATTIC_CACHE")
ATTIC_KEYS=$(abspath "$ATTIC_KEYS")
BACKUP_ROOT=$(abspath "$BACKUP_ROOT")
SSH_ID=$(abspath "$SSH_ID")
SSH_KNOWN_HOSTS=$(abspath "$SSH_KNOWN_HOSTS")

docker run \
    --privileged --device=/dev/fuse \
    --name backuper \
    --rm \
    -v "$SSH_KNOWN_HOSTS":/known_hosts:ro \
    -v "$SSH_ID":/id_rsa:ro \
    -v "$ATTIC_KEYS":/root/.attic:rw \
    -v "$ATTIC_CACHE":/root/.cache:rw \
    -v "$BACKUP_ROOT":/b:"$BACKUP_MOUNT_FLAGS" \
    -e KEEP_DAILY="$KEEP_DAILY" \
    -e SSH_PATH="$SSH_PATH" \
    -e BACKUP_PATHS="$BACKUP_PATHS" \
    -e EXCLUDES="$EXCLUDES" \
    backuper run.sh $@