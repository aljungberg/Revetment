SSH_PATH="3753@usw-s003.rsync.net:test/"
SSH_KNOWN_HOSTS="$PWD/test/known_hosts"
SSH_ID="$PWD/test/id_rsa"
BACKUP_ROOT="$PWD/test/backup/"
ATTIC_KEYS="$PWD/test/attic"
ATTIC_CACHE="$PWD/test/cache"
KEEP_DAILY=2

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
    -e KEEP_DAILY="$KEEP_DAYS" \
    -e SSH_PATH="$SSH_PATH" \
    -e BACKUP_PATHS="1.txt \"path with space\"/dog.txt proc" \
    -e EXCLUDES="/proc /dev /tmp /var/tmp /var/log /var/cache /media /lost+found" \
    backuper run.sh $@