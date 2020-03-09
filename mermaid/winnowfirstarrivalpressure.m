function [FAP, idx, zerflag_idx, perc, FAP_0, rm_idx] = ...
    winnowfirstarrivalpressure(filename1, filename2, max_tres, max_twosd, min_snr)
% [FAP, idx, zerflag_idx, perc, FAP_0, rm_idx] = ...
%      WINNOWFIRSTARRIVALPRESSURE(filename1, filename2, max_tres, max_twosd, min_snr)
%
% Winnows output of readfirstarrivalpressure.m based on input
% winnowing parameters send to winnowfirstarrival.m.
%
% See readfirstarrivalpressure.m for the meaning of the fields in FAP.
%
% Input:
% filename1    File name of file written by writefirstarrivalpressure.m
%                  (def: $MERMAID/.../firstarrivalpressure.txt)
% filename2    File name of file written by writefirstarrival.m
%                  (def: $MERMAID/.../firstarrival.txt)
% max_tres     QC parameter: tres(idx) <= max_tres (def; realmax)
% max_twosd    QC parameter: twosd(idx) <= max_twosd (def; realmax)
% min_snr      QC parameter: SNR(idx) >= max_twosd (def: realmin)
%
% Output:
% FAP           Structure of winnowed first-arrival pressure data
%                  s.t. isequaln(FAP.s, FAP_0.s(idx))
% idx          Indices that fall within winnowing criteria
% zerflag_idx* Indices of where zerflag is true
% perc*        Percentage of data that make it through winnowing
% FAP_0        Structure of complete (unwinnowed) first arrival data
% rm_idx*      Indices removed (did not pass quality control)
%
% *same as returned by winnowfirstarrival.m
%
% 'idx' DOES NOT include rows with 'winflag' (incomplete window(s)) or
% 'tapflag' (incomplete taper) true sentinel values.  I.e., if a row
% has in incomplete taper it is removed from contention here and not
% returned with the list of "good" indices in idx.
%
% 'idx' DOES include rows with 'zerflag' (possible zero-filled/data
% missing file) because 'zerflag' is not a perfect test: it tests if
% two or more contiguous sample indices in the data have values equal
% to exactly 0, which can actually happen with real data and does not
% necessarily mean the data were zero-filled.  Those indices are
% returned separately for further inspection as 'zerflag_idx', though
% note they are also included in idx so be careful.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 07-Mar-2020, Version 2017b on GLNXA64

% Defaults.
defval('filename1', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                             'identified', 'txt', 'firstarrivalpressure.txt'))
defval('filename2', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                             'identified', 'txt', 'firstarrival.txt'))
defval('max_tres', realmax)
defval('max_twosd', realmax)
defval('min_snr', realmin)
high_tres = [];
high_twosd = [];
low_snr = [];

% Read the first-arrival pressure file.
[s, ph, RMS, P, magval, magtype, depth, dist, merlat, merlon, evtlat, evtlon, ID, winflag, tapflag, zerflag] ...
    = readfirstarrivalpressure(filename1);

% Find the relevant lines to keep using winnowfirstarrival.m
[~, idx, zerflag_idx, perc, FA_0, rm_idx] = winnowfirstarrival(filename2, max_tres, max_twosd, min_snr);

% Find the SAC files in the winnowed first arrival file that are also in the LLNL file.
[~, inter_idx] = intersect(s, FA_0.s);

% Log the complete, original data for inspection, maybe.
FAP_0.filename = filename1;
FAP_0.s = s(inter_idx);
FAP_0.ph = ph(inter_idx);
FAP_0.RMS = RMS(inter_idx);
FAP_0.P = P(inter_idx);
FAP_0.magval = magval(inter_idx);
FAP_0.magtype = magtype(inter_idx);
FAP_0.depth = depth(inter_idx);
FAP_0.dist = dist(inter_idx);
FAP_0.merlat = merlat(inter_idx);
FAP_0.merlon = merlon(inter_idx);
FAP_0.evtlat = evtlat(inter_idx);
FAP_0.evtlon = evtlon(inter_idx);
FAP_0.ID = ID(inter_idx);
FAP_0.winflag = winflag(inter_idx);
FAP_0.tapflag = tapflag(inter_idx);
FAP_0.zerflag = zerflag(inter_idx);

% Remove all incomplete cases.
FAP.filename = filename1;
FAP.s = FAP_0.s(idx);
FAP.ph = FAP_0.ph(idx);
FAP.RMS = FAP_0.RMS(idx);
FAP.P = FAP_0.P(idx);
FAP.magval = FAP_0.magval(idx);
FAP.magtype = FAP_0.magtype(idx);
FAP.depth = FAP_0.depth(idx);
FAP.dist = FAP_0.dist(idx);
FAP.merlat = FAP_0.merlat(idx);
FAP.merlon = FAP_0.merlon(idx);
FAP.evtlat = FAP_0.evtlat(idx);
FAP.evtlon = FAP_0.evtlon(idx);
FAP.ID = FAP_0.ID(idx);
FAP.winflag = FAP_0.winflag(idx);
FAP.tapflag = FAP_0.tapflag(idx);
FAP.zerflag = FAP_0.zerflag(idx);
