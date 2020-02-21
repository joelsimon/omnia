# Simple python script to convert station.xml response files to SAC
# pole-zero files.  Filename convention is maintained and extension
# .xml is replaced with .pz.  Input .xml file is removed from system
# after execution.
#
# Requires obspy and is intended to be used within the MERMAID python
# environment 'pymaid'.
#
# Input: .xml filename (e.g., AM.RF737.00.Z.xml)
# Output: .pz filename (e.g., AM.RF737.00.Z.pz)
#
# Ultimately for me this calls: ~/.conda/envs/pymaid/lib/python2.7/site-packages/obspy/io/sac/sacpz.m
#
# You can you see it conforms with the SEED convention of converting
# STATION XML response files from their native unit (e.g., velocity in
# meters per second) to displacement (meters) by adding the correct
# number of zeros and updating the CONSTANT accordingly (in units of
# displacement, meters).
#
# See $MERMAID/events/nearbystations/pz/examples/XML2PZ_example where
# this is confirmed, specifically that a velocity RESP file is
# correctly converted to displacement SACPZ file.
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
