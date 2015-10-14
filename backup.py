#!/usr/bin/env python3

# Use Python to ensure we quote all arguments properly even when they come from env vars and contain spaces.

import shlex
import os
import sys
import datetime

def strip_paths(paths):
    return [os.path.normpath("./" + l) for l in shlex.split(paths)]

repo = os.path.join(os.getenv("SSHFS_MOUNT"), os.getenv("BACKUP_NAME", "backup.attic"))

if sys.argv[1] == 'check':
    args = [
        "check",
        "-v",
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
        "-v",
        "--stats",
        "--exclude-caches",
        "--do-not-cross-mountpoints",
        "%s::%s" % (repo, name)  
    ]

    for exclude in strip_paths(os.getenv("EXCLUDES")):
        args += ["--exclude", exclude]

    args += strip_paths(os.getenv("BACKUP_PATHS"))

# sys.stdout.write("cwd: %s args: %r\n" % (os.getcwd(), args))
# sys.stdout.flush()

os.execvp("attic", ["attic"] + args)
