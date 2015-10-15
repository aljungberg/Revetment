### Take backups with Attic

Dockerised version of Attic operating against any SCP/SSH host through sshfs.

Benefits:

- Only 1 dependency: Docker.
- Secure: read-only mount of what is being backed up.
- Secure: any security flaws in sshfs or Attic are mitigated through sandboxing.

The main advantage of using this tool is that it has only a single dependency: Docker. This is very helpful when installing on various old running machines on LTS releases that might not have Python 3 and all the other things Attic requires.

The other benefit is security. If the backup software is compromised the attacker can only read the data to be backed up. That's still bad but at least the attacker can't take over the server without an additional Docker jailbreak compromise. Unlike normal backup scripts which often need read-write access to the whole machine, Attic has read-only access only in this setup.


#### Usage

#### Setup

    cp backup-sample.sh backup.sh  
    pico backup.sh   # choose backup parameters

#### Take a backup

    backup.sh create [archive name]  # defaults to making an archive named by YYYY-MM-DD date stamp.
    
#### Verify a backup

    backup.sh check
    
#### Inspect backups
    
    backup.sh list
    backup.sh list 2015-10-13
    
#### Restore a backup

    # restore files to the given destination folder
    backup.sh extract <archive name> <destination> [file1 [file2 ...]]
    
    
