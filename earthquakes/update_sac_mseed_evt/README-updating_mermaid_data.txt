"How to Update .mseed/.sac (automaid) and .evt (omnia) Files"

NB: at this time, when automaid v3.6+ has not been merged to the
EarthScope-Oceans master branch on github, we must use the v3.6.0 development
branch.

Author: Joel D. Simon
Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
Last modified: 17-May-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

__________

TL;DR: Going forward must run automaid >= v3.5.1, omnia >= v1.0.0; remake
       .sac/.mseed/.evt files generated before then with either of those codes.

Preliminaries:

(1) Ensure update to date with both codebases

   $ cd $AUTOMAID; git checkout v3.6.0 ; git pull
   $ cd $OMNIA ; git pull


(2) Backup existing processed/ and events/ directories, either with git or
    actual recursive directory copies

%% ___________________________________________________________________________ %%
%% Updating $MERMAID/processed/ (automaid; .mseed & .sac files)                %%
%% ___________________________________________________________________________ %%

The problem:

* v3.5.1 introduce GPS interpolation fix that corrected issue if MERMAID crossed
  anti-meridian during dive.  Locations may have changed in .sac headers which
  will has cascade effect through entire processing scheme.

* Joel has introduced various improvements over the years in how timing/location
  from .LOG/.MER are "merged" together, so any processed data generated from
  earlier automaid versions may have slightly different times and locations.

!! The fix:
!! * Run main.py with `redo=True`

Regenerate entire processed directory and check for diffs in:
(1) .mseed changes (hopefully mostly unchanged; there is timing, but no location info .mseed)
(2) .sac changes (will be changed due to version number in header)
(3) loc.txt (check for location updates, e.g. due to v3.5.1 fix)
(4) gps_interpolation.txt (similar to loc.txt; timing/location diffs will show here)

* Algorithm to correct starttime in Joel's newer automaid versions may
  differently merged .LOG/.MER times/locations as input resulting in slightly
  different times in the data; timing changes (but not location changes) will
  show up as .mseed diffs.

%% ___________________________________________________________________________ %%
%% Updating MERMAID/events/ (omnia; .evt files)
%% ___________________________________________________________________________ %%

The problem:

* omnia < v1.0.0 has timing (code bug) issue in seistime.m: .sac header field
  NZMSEC was not properly zero padded so that, e.g.,

  NZMSEC: 9 -> incorrectly set as 0.9 s instead of 0.009 s
  NZMSEC: 99 -> incorrectly set as 0.99 s instead of 0.099 s

So there exists a timing error if the integer value in NZMSEC was length 1 or
2.  About 10% of integers between [0:1:1000] are less than length 3 (<=99), so
we'd expect about 10% of data processed with this buggy omnia to have timing
errors. The timing errors would be for any 1 <= NZMSEC <= 99, so basically about
0.5 seconds on average.  All errors are in the positive direction (reported
starttime later than truth), so all corrected starttimes should be earlier.

This problem is most noted in EQ.TaupTimes (phase-arrival time sub-structures in
the .evt files).  We need to rewrite those .TaupTimes.

!! The fix:
!! * Run updatetauptimesall.m

* Note: the above ONLY overwrites bad .evt files (does not alter any .txt
  files), so as a final step you will want to rewrite all .txt files using
  evt2txt.m, writefirstarrivals., etc.

Warnings:

* updatetauptimes.m and updatetauptimesall.m will only alter reviewed and
  identified .evt files; raw and unidentified .evt files are not touched. This
  means that if you ever re-review decide that an unidentified .evt is now an
  identified .evt, you must again check if the .TaupTimes need to be updated.

* udpateid.m is similar to updatetauptimes.m except there is one important
  difference: updateid.m only checks for differences in the event metadata
  (e.g., EQ.PreferredLatitude) between all .evt files that match that earthquake
  ID -- it does not recompute EQ.TaupTimes unless those event metadata differ,
  or `force=true`.

* .cp files and their required updates were not addressed here; Joel has stopped
  writing those for most events because they are computationally expensive. He
  prefers instead to write text files of P-wave arrival times, e.g., with like
  with writefirstarrival.m. Please be careful to not mix corrected .evt and
  uncorrected .cp arrival times before tomography. Talk to Joel if you need
  help.

__________

Final thought:

updateidall.m with `force=true` will (1) re-fetch the most up-to-date (according
to IRIS, which is not actually that up to date compared to USGS, for example)
event metadata for all matching .evt files and recompute EQ.TaupTimes for those
new metadata (or recompute the same .TaupTimes if event metadata unchanged and
the .TaupTimes was already corrected).  It is suggested that before any
tomography updateidall.m with `force=true` be run just to ensure a clean evt
directory.  Better still would be to write a similar code that actually gets the
"final" event metadata from ISC directory and rewrites all .evt from there, but
such a code remains to be written.
