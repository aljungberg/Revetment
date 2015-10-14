#!/bin/bash

SSH_PATH="3753@usw-s003.rsync.net:test/"
SSH_KNOWN_HOSTS="$PWD/test/known_hosts"
SSH_ID="$PWD/test/id_rsa"
BACKUP_ROOT="$PWD/test/backup/"
ATTIC_KEYS="$PWD/test/attic"
ATTIC_CACHE="$PWD/test/cache"
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
"


set -xe

BACKUP_MOUNT_FLAGS="ro"

if [[ "$1" == "extract" ]]; then
    BACKUP_ROOT="$2"
    mkdir -p "$BACKUP_ROOT"
    BACKUP_MOUNT_FLAGS="rw"
fi

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