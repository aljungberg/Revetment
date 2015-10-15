#!/bin/bash

# SFTP (SSH) path to back up to.
SSH_PATH="example.com:test/"

# Where to keep attic encryption keys. Default: ~/.attic.
# ATTIC_KEYS=~/.attic

# Where to keep attic cache files. Default: ~/.cache.
# ATTIC_CACHE=~/.cache

# 1 backup per day will be kept for up to this many days. Default: 2.
# KEEP_DAILY=2

# Folder to back up.
BACKUP_ROOT="test/backup/"

# What to back up within BACKUP_ROOT. One name per line. Use ./ to back up everything in BACKUP_ROOT. Default: ".".
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

source backup.sh $@
