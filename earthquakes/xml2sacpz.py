# Simple script to convert station xml response files to SAC poles and
# zeros files.
#
# Requires obspy and is intended to be used within the MERMAID python
# environment: pymaid
#
# Author: Joel D. Simon
# Contact: jdsimon@princeton.edu
# Last modified: 16-Nov-2019, Python 2.7.15

import sys
import os
from obspy import read_inventory

filename = str(sys.argv[1])
root, ext = os.path.splitext(filename)

inv = read_inventory(filename)
inv.write(root + '.sacpz', format='SACPZ')

os.remove(filename)


