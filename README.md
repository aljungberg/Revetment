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

    docker pull aljungberg/revetment
    curl https://raw.githubusercontent.com/aljungberg/Revetment/master/backup.sh >backup.sh

#### Configure and initialise

    curl https://raw.githubusercontent.com/aljungberg/Revetment/master/my-backup-sample.sh >my-backup.sh
    pico my-backup.sh   # choose backup parameters
    my-backup.sh init

#### Take a backup

    my-backup.sh create [archive name]  # defaults to making an archive named by YYYY-MM-DD date stamp.
    
#### Verify a backup

    my-backup.sh check
    
#### Inspect backups
    
    my-backup.sh list
    my-backup.sh list 2015-10-13
    
#### Restore a backup

    # restore files to the given destination folder
    my-backup.sh extract <archive name> <destination> [file1 [file2 ...]]
    
