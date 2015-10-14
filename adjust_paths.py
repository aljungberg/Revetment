#!/usr/bin/env python3

import shlex
import os
import sys

for l in shlex.split(sys.argv[1]):
    print(os.path.normpath("./" + l))
