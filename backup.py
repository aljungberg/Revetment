#!/usr/bin/env python3

"""
Attic wrapper which handles excludes and includes as a new-line separated list
of patterns (to allow spaces in names), and which normalises and relativises path 
names. The normalisation ensures that the CWD is considered the "root" of the archive
and gives each archived file a more canonical name.

This works around a problem in Attic where it doesn't normalise paths. Consider a FS
with "cat.txt" in it. If you back up "./", Attic will think of this file as "./cat.txt"
and apply exclude patterns based on that. But on the other hand if you actually back
up "cat.txt", Attic will think of this file as just that, "cat.txt". And if you back up
"./cat.txt" it will /also/ think of it as "cat.txt" -- there is no way to get it to
think of it as what you'd get with ".".

So for consistency we always use absolute paths from the backup root (/b/).
""" 

import shlex
import os
import sys
import datetime

def strip_paths(paths):
    """Ensure all paths are normalised and begin with '/b/'."""
    return (os.path.normpath("/b/" + path) for path in paths if len(path))

repo = os.path.join(os.getenv("SSHFS_MOUNT"), os.getenv("BACKUP_NAME", "backup.attic"))

if sys.argv[1] == 'check':
    args = [
        "check",
        repo
    ]
elif sys.argv[1] == 'list':
    args = [
        "list",
    ]
    if len(sys.argv) > 2:
        args += ["%s::%s" % (repo, sys.argv[2]), ]
        args += sys.argv[3:]
    else:
        args += [repo, ]
elif sys.argv[1] == 'delete':
    args = [
        "delete",
    ]
    args += ["%s::%s" % (repo, sys.argv[2]), ]
    args += sys.argv[3:]
elif sys.argv[1] == 'extract':
    args = [
        "extract",
        "%s::%s" % (repo, sys.argv[3]),
    ] + sys.argv[4:]
elif sys.argv[1] == 'create':
    name = sys.argv[2] if len(sys.argv) > 2 else datetime.date.today().isoformat()
    args = [
        "create",
        "--stats",
        "--numeric-owner",  # we don't have usernames anyhow due to being in Docker
        "--exclude-caches",
        "--do-not-cross-mountpoints",
        "%s::%s" % (repo, name)  
    ]

    for exclude in strip_paths(os.getenv("EXCLUDES").split("\n")):
        args += ["--exclude", exclude]

    args += list(strip_paths(os.getenv("BACKUP_PATHS").split("\n")))

# sys.stdout.write("cwd: %s args: %r\n" % (os.getcwd(), args))
# sys.stdout.flush()

os.execvp("attic", ["attic"] + args)
