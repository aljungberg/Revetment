#!/bin/bash

set -e

TARGET_DIR=/root/revetment/

promptYesOrNo() {
  __default="n"
  __default_note="y/N"
  if [ "$2" == "y" ]; then
    __default="y"
    __default_note="Y/n"
  fi

  read -p "$1 ($__default_note) " __r
  
  [ -z "$__r" ] && __r="$__default"

  [ "$__r" == "y" -o "$__r" == "Y" ]
}

install() {
  echo "Warning: this installer will overwrite files in $TARGET_DIR. This script is delivered as is, with no guarantees. It could wipe your system."
  
  if ! promptYesOrNo "Risk everything?" n ; then
    exit 0
  fi

  mkdir -p "$TARGET_DIR"
  cd "$TARGET_DIR"

  curl -O https://raw.githubusercontent.com/aljungberg/Revetment/master/backup.sh -O https://raw.githubusercontent.com/aljungberg/Revetment/master/my-backup-sample.sh

  [ -f "my-backup.sh" ] || cp my-backup-sample.sh my-backup.sh

  editor="$VISUAL"
  command -v "$editor" >/dev/null 2>&1 || editor="$EDITOR"
  command -v "$editor" >/dev/null 2>&1 || editor="pico"

  $editor my-backup.sh
  
  if $(cmp --silent my-backup-sample.sh my-backup.sh ); then
    echo "No settings configured. Aborting."
    exit 0
  fi
  
  source my-backup.sh env
   
  BACKUP_CRON="0 2 * * * root HOME=/root/ /bin/bash '$TARGET_DIR'/my-backup.sh create >/var/log/backup.log 2>&1"
  grep -q -F "$BACKUP_CRON" /etc/crontab || (echo "Adding to crontab..." ; echo "$BACKUP_CRON" >>/etc/crontab)
    
  echo "All done. Assuming this is a new archive, run:"
  echo "    bash my-backup.sh init"
  echo "Copy your attic keys ($ATTIC_KEYS) somewhere safe then run:"
  echo "    bash my-backup.sh create"
}

install
