#!/usr/bin/env python3

"""
Attic wrapper which handles excludes and includes as a new-line separated list
of patterns (to allow easy spaces in names), and which normalises and
relativises path names. The normalisation gives each archived file a name
relative to the backup root and a more canonical name.

The canonical name bit works around a problem in Attic. Consider a FS with
"cat.txt" in it. If you back up "./", Attic will think of this file as
"./cat.txt" and apply exclude patterns based on that. But on the other hand if
you actually back up "cat.txt", Attic will think of this file as just that,
"cat.txt". And if you back up "./cat.txt" it will /also/ think of it as
"cat.txt" -- there is no way to get it to think of it as what you'd get with
".".

So for consistency we always use absolute paths from the backup root (/b/).
""" 

import shlex
import os
import sys
import datetime

def strip_paths(paths):
    """Ensure all paths are normalised and begin with '/b/'."""
    return (os.path.normpath("/b/" + path) for path in paths if len(path))

def extract_optional_args(sys_args, optional_args):
    r = []
    sys_args = sys_args[:]

    for a in optional_args:
        a, has_param = (a[:-1], True) if ":" in a else (a, False)
        if not a in sys_args:
            continue    
        i = sys_args.index(a)
        r.append(sys_args.pop(i))
        if has_param:
            r.append(sys_args.pop(i))
    
    return r, sys_args


repo = os.path.join(os.getenv("SSHFS_MOUNT"), os.getenv("BACKUP_NAME", "backup.attic"))
sys_args = sys.argv[:]

if sys_args[1] == 'check':
    args = [
        "check",
        repo
    ]
elif sys_args[1] == 'list':
    args = [
        "list",
    ]
    if len(sys_args) > 2:
        args += ["%s::%s" % (repo, sys_args[2]), ]
        args += sys_args[3:]
    else:
        args += [repo, ]
elif sys_args[1] == 'delete':
    args = [
        "delete",
    ]
    args += ["%s::%s" % (repo, sys_args[2]), ]
    args += sys_args[3:]
elif sys_args[1] == 'extract':
    # Pass through -v and -c.
    optional_args, remaining_args = extract_optional_args(sys_args, ('-h', '-n', '--dry-run', '-v', '--verbose', '--numeric-owner'))

    args = [
        "extract",
        "--strip-components", "1",  # extract right into /b/ rather than /b/b.
    ]
    
    args += optional_args

    args += ["%s::%s" % (repo, remaining_args[2]),]

    # Actual files to extract need to be normalised too. E.g. to extra file1.txt, turn it into /b/file1.txt.
    args += [p[1:] for p in strip_paths(remaining_args[4:])]
elif sys_args[1] == 'create':
    name = sys_args[2] if len(sys_args) > 2 else datetime.date.today().isoformat()
    args = [
        "create",
        "--stats",
        "--numeric-owner",  # we don't have usernames anyhow due to being in Docker
        "--exclude-caches",
        "--do-not-cross-mountpoints",
        "%s::%s" % (repo, name)  
    ]
    
    # Pass through -v and -c.
    optional_args, remaining_args = extract_optional_args(sys_args, ('-h', '-v', '--verbose', "-c:", "--checkpoint-interval:"))
    args.extend(optional_args)

    for exclude in strip_paths(os.getenv("EXCLUDES").split("\n")):
        args += ["--exclude", exclude]

    args += list(strip_paths(os.getenv("BACKUP_PATHS").split("\n")))
else:
    raise ValueError("unknown command")

# sys.stdout.write("cwd: %s args: %r\n" % (os.getcwd(), args))
# sys.stdout.flush()

os.execvp("attic", ["attic"] + args)
