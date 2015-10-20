## Revetment

Extra secure, encrypted, deduplicated, compressed backups against any SFTP (SSH) host.

Revetment is a Dockerised version of the [Attic](https://attic-backup.org/) backup tool.

- Single dependency: Docker.
- Flexible: compatible with any SFTP backup server (rsync.net, the server in your closet).
- Secure: backup process has root-like read access to all files, yet no write access.
- Sandboxed: an extra layer of protection to mitigate potential security flaws in sshfs or Attic.
- Always on encryption: no unencrypted data ever leaves the machine.
- Attic's regular benefits: variable block size deduplication, 256 bit AES encryption with keyfiles, compression, very fast and space efficient when little data has changed.

The main advantage of using Revetment is that it only depends on Docker (and Bash). When you need to back up old LTS servers, it might not be easy or advisable to install Python 3 and the other Attic dependencies. With Revetment, just add Docker.

The other benefit is security. Normally you must run your backup scripts as root so that any and all files may be backed up. Revetment also requires root but drops the write access and many other root privileges as soon as possible. This means that a compromise in the backup software itself is, although still bad, unlikely to damage the server being backed up.

### Usage

#### Install

    curl https://raw.githubusercontent.com/aljungberg/Revetment/master/backup.sh >backup.sh

#### Configure and initialise

    curl https://raw.githubusercontent.com/aljungberg/Revetment/master/my-backup-sample.sh >my-backup.sh
    pico my-backup.sh   # choose backup parameters
    bash my-backup.sh init
    # copy ~/.attic/keys/ somewhere safe.

#### Take a backup

    bash my-backup.sh create [archive name]  # defaults to making an archive named by date in YYYY-MM-DD format.
    
#### Make it regular

    echo '0 2 * * * root HOME=/root/ /bin/bash /root/my-backup.sh create >/var/log/backup.log 2>&1' >>/etc/crontab
    
#### Verify a backup

    bash my-backup.sh check
    
#### Inspect backups
    
    bash my-backup.sh list
    bash my-backup.sh list 2015-10-13
    
#### Restore a backup

    # restore files to the given destination folder
    bash my-backup.sh extract <archive name> <destination> [file1 [file2 ...]]

### Good habits

- Remember to verify your backups regularly: use `bash my-backup.sh check`.
- Extract some files from every new backup using a different machine than the one taking the backups to confirm that you have the ability to (you copied the SSH keys and attic keys you need).

