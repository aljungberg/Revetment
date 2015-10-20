#!/bin/bash

# SFTP (SSH) path to back up to.
SSH_PATH="example.com:test/"

# Where to keep attic encryption keys. Default: ~/.attic.
# ATTIC_KEYS=~/.attic

# Where to keep attic cache files. Default: ~/.cache.
# ATTIC_CACHE=~/.cache

# 1 backup per day will be kept for up to this many days. Default: 2.
# KEEP_DAILY=2

# Root of the file system to back up. Default: /.
# BACKUP_ROOT="/"

# What to back up within BACKUP_ROOT. One name per line. Use ./ to back up everything in BACKUP_ROOT. Default: ".".
# Note that the "do not cross mount points" option is in use so to back up more than one partition, specify each.
BACKUP_PATHS="
file1
file2
"

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

### End configuration -- don't edit below this line. ###

if [[ -e "./backup.sh" ]]; then
    source ./backup.sh $@
else
    source $(dirname "$0")/backup.sh $@
fi
