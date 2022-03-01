function [F, EQ, sac] = recordsection(id, lohi, alignon, ampfac, evtdir, ...
                                      procdir, normlize, returntype, ph, popas, ...
                                      taper, incl_prelim)
% [F, EQ, sac] = RECORDSECTION(id, lohi, alignon, ampfac, evtdir, procdir, ...
%                              normlize, returntype, ph, popas, taper, incl_prelim)
%
% Plots a record section of all MERMAID seismograms that recorded the
% same event, according to 'identified.txt' (output of evt2txt.m)
%
% Input:
% id        Event identification number (def: 10948555)
% lohi      Bandpass corner frequencies [Hz] (Butterworth filter),
%               or NaN to plot raw seismograms  (def: [1 5])
% aligon    'etime': t=0 at event rupture time (def: etime)
%           'atime': t=0 at theoretical first arrival
%                    for every seismogram*
% ampfac    Nondimensional amplitude multiplication factor (def: 3)
% evtdir    Path to 'events' directory
%                (def: $MERMAID/events/)
% procdir   Path to 'processed' directory
%                (def: $MERMAID/processed/)
% normlize  true: normalize each seismogram against itself (def: true)
%                 (removes 1/dist amplitude decay)
%           false: normalize each seismogram against ensemble
%                 (preserves 1/dist amplitude decay)
% returntype   For third-generation+ MERMAID only:
%              'ALL': both triggered and user-requested SAC files
%              'DET': triggered SAC files as determined by onboard algo. (def)
%              'REQ': user-requested SAC files
% ph        Comma separated list of phases to overlay travel time curves
%               (def: the phases present in the corresponding .evt files)
% popas     1 x 2 array of number of poles and number of passes for bandpass
%               (def: [4 1])
% taper     0: do not taper before bandpass filtering (if any)
%           1: (def) taper with 0.1-ratio Tukey (`tukeywin`) before filtering
%           2: taper with Hann (`hanning`) before filtering
% incl_prelim true to include 'prelim.sac'
%
% Output:
% F        Structure with figure handles and bits
% EQ       EQ structure returned by cpsac2evt.m
% sac      SAC files whose traces are plotted
%
% *Theoretical travel time curves are not plotted if alignon = 'atime'.  Also
% note that a vertical line at 0 seconds does not necessarily correspond to the
% same phase / phase branch across different seismograms.  I.e., the 0 time for
% each seismogram is individually set to its first arrival, even if that
% first-arriving phase is different from the first-arriving phase of other
% seismograms plotted.  In the vast majority of cases the first-arriving phase
% be the same across all seismograms, but this is something to be aware
% of. Overlaid travel time curves for 'atime' option are on the wish list.
%
% Ex:
% RECORDSECTION(10948555, [], 'etime');
% RECORDSECTION(10948555, [], 'atime');
% RECORDSECTION(10937540, [1/10 1/2], 'etime', 3, [], [], true);
% RECORDSECTION(10937540, [1/10 1/2], 'etime', 3, [], [], false);
%
% See also: recordsectioneq.m, evt2txt.m, getevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Jan-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('id', '10948555')
defval('lohi', [1 5]);
defval('alignon', 'etime')
defval('ampfac', 3)
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
defval('normlize', true)
defval('returntype', 'DET')
defval('ph', []);
defval('popas', [4 1]);
defval('taper', 1)
defval('incl_prelim', true)

% Find all the SAC files that match this event ID.
id = num2str(id);
sac = getsac(id, evtdir, procdir, returntype, incl_prelim);
if isempty(sac)
    F = [];
    EQ = [];
    return

end
EQ = getrevevt(sac, evtdir);

% This is essentially now a wrapper for `recordsectioneq`, which more or less
% contains the guts of this original function. Future development should go in
% there, not here, where SAC and EQ lists are directly input.
[F, EQ, sac] = recordsectioneq(sac, EQ, lohi, alignon, ampfac, normlize, ph, ...
                               popas, taper)
