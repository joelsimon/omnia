# Simple python script to convert station.xml response files to SAC
# pole-zero files.  Filename convention is maintained and extension
# .xml is replaced with .pz.  Input .xml file is removed from system
# after execution.
#
# Input: .xml filename (e.g., AM.RF737.00.Z.xml)
# Output: .pz filename (e.g., AM.RF737.00.Z.pz)
#
# Requires obspy and is intended to be used within the MERMAID python
# environment 'pymaid'.
#
# Author: Joel D. Simon
# Contact: jdsimon@princeton.edu
# Last modified: 16-Nov-2019, Python 2.7.15 (pyamid env.)

import sys
import os
from obspy import read_inventory

# Read .xml file.
filename = str(sys.argv[1])
root, ext = os.path.splitext(filename)
inv = read_inventory(filename)

# Convert .xml file to .pz file.
inv.write(root + '.pz', format='SACPZ')

# Remove .xml file.
os.remove(filename)
