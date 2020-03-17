function [LL, idx, zerflag_idx, perc, LL_0, rm_idx] = ...
    winnowllnl(filename1, filename2, max_tres, max_twosd, min_snr, rmsac)
% [LL, idx, zerflag_idx, perc, LL_0, rm_idx] = ...
%      WINNOWLLNL(filename1, filename2, max_tres, max_twosd, min_snr, rmsac)
%
% Winnows output of readllnl.m based on input winnowing parameters
% send to winnowfirstarrival.m.
%
% See readllnl.m for the meaning of the fields in LL.
%
% Input:
% filename1    File name of file read by by readllnl.m
%                  (def: $SIMON2020_CODE/3D/JessData_brief_results.out)
% filename2    File name of file written by writefirstarrival.m
%                  (def: $MERMAID/.../firstarrival.txt)
% max_tres     QC parameter: tres(idx) <= max_tres (def; realmax)
% max_twosd    QC parameter: twosd(idx) <= max_twosd (def; realmax)
% min_snr      QC parameter: SNR(idx) >= max_twosd (def: realmin)
% rmsac        Cell of any other SAC files to remove, for whatever reason
%
% Output:
% LL           Structure of winnowed LLNL-G3Dv3 data
%                  s.t. isequaln(LL.s, LL_0.s(idx))
% idx          Indices that fall within winnowing criteria
% zerflag_idx* Indices of where zerflag is true
% perc*        Percentage of data that make it through winnowing
% LL_0         Structure of complete (unwinnowed) LLNL-G3Dv3 data
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
% Last modified: 17-Mar-2020, Version 2017b on MACI64

% Defaults.
defval('filename1', fullfile(getenv('SIMON2020_CODE'), 'data' , 'JessData_brief_results.out'))
defval('filename2', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                             'identified', 'txt', 'firstarrival.txt'))
defval('max_tres', realmax)
defval('max_twosd', realmax)
defval('min_snr', realmin)
defval('rmsac', [])
high_tres = [];
high_twosd = [];
low_snr = [];

% Read the LLNL-G3Dv3 textfile.
[s, d3_d1, d1_tptime, d3_tptime, gcdiff, d1gc, watercorr, ph] = readllnl(filename1);

% Find the relevant lines to keep using winnowfirstarrival.m
[~, idx, zerflag_idx, perc, FA_0, rm_idx] = ...
    winnowfirstarrival(filename2, max_tres, max_twosd, min_snr, rmsac);

% Find the SAC files in the winnowed first arrival file that are also in the LLNL file.
[~, inter_idx] = intersect(s, FA_0.s);

% Log the complete, original data for inspection, maybe.
LL_0.filename = filename1;
LL_0.s = s(inter_idx);
LL_0.d3_d1 = d3_d1(inter_idx);
LL_0.d1_tptime = d1_tptime(inter_idx);
LL_0.d3_tptime = d3_tptime(inter_idx);
LL_0.gcdiff = gcdiff(inter_idx);
LL_0.d1gc = d1gc(inter_idx);
LL_0.watercorr = watercorr(inter_idx);
LL_0.ph = ph(inter_idx);

% Remove all incomplete cases.
LL.filename = filename1;
LL.s = LL_0.s(idx);
LL.d3_d1 = LL_0.d3_d1(idx);
LL.d1_tptime = LL_0.d1_tptime(idx);
LL.d3_tptime = LL_0.d3_tptime(idx);
LL.gcdiff = LL_0.gcdiff(idx);
LL.d1gc = LL_0.d1gc(idx);
LL.watercorr = LL_0.watercorr(idx);
LL.ph = LL_0.ph(idx);
