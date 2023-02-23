function [tres, dat, syn, tadj, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, SNR, EQ, W1, xw2, W2, winflag, tapflag, zerflag, xax0] = firstarrival_unidentified(s, ci, wlen, lohi, sacdir, bathy, wlen2, fs, popas)
% [tres, dat, syn, tadj, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, SNR, EQ, W1, xw2, W2, winflag, tapflag, zerflag, xax0] ...
%     = firstarrival_unidentified(s, ci, wlen, lohi, sacdir, bathy, wlen2, fs, popas)
%
% Compute first-arrivals like in `firstarrival.m` but for unidentified SAC
% files.  Assumes P wave incident at 0 degrees on seafloor arrives at 100 s into
% the seismogram (counting from 0 seconds).  See `firstarrival.m` for I/0.
%
% This is literally just a wrapper for `firstarrival.m` with a "fake" EQ
% structure generated on the fly here and fed there to replicate an observed
% arrival at 100 s.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('s', '20180810T055938.09_5B6F01F6.MER.DET.WLT5.sac')
defval('ci', true)
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('bathy', true)
defval('wlen2', 1.75)
defval('fs', []) % defaults to not bandpass filter
defval('popas', [4 1])

% Make all times in reference to start of seismogram, ("start counting from 0"),
% not offsets from the SAC reference time (h.B).
pt0 = 0;
evtdir = 'foo';

% Nab fullpath SAC file name, if not supplied.
if isempty(fileparts(s))
    s = fullsac(s, sacdir);

end
[~, h] = readsac(s);

% Make "fake" EQ structure with "P-wave" arrival at 100 seconds.
EQ.Filename = strippath(s);
EQ.TaupTimes.pt0 = h.B;
EQ.TaupTimes.truearsecs = 100 + h.B;
EQ.TaupTimes.phaseName = 'P';
EQ.TaupTimes.model = 'ak135';
EQ.TaupTimes.incidentDeg = 0;
EQ.PreferredMagnitudeType = 'XX';
EQ.PreferredMagnitudeValue = -12345;
EQ.PreferredDepth = -12345;
EQ.TaupTimes.distance = -12345;

[tres, dat, syn, tadj, ph, delay, twosd, xw1, xaxw1, maxc_x, maxc_y, SNR, EQ, W1, xw2, W2, winflag, tapflag, zerflag, xax0] = ...
        firstarrival(s, ci, wlen, lohi, sacdir, evtdir, EQ, bathy, wlen2, fs, popas, pt0);

% [f, ax, tx, pl, FA] = ...
%         plotfirstarrival(s, [], [], EQ, ci, wlen, lohi, sacdir, evtdir, bathy, wlen2, fs, popas, pt0)
