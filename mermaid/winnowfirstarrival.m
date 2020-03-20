function [FA, idx, zerflag_idx, perc, FA_0, rm_idx] = ...
    winnowfirstarrival(filename, max_tres, max_twosd, min_snr, ph, rmsac)
% [FA, idx, zerflag_idx, perc, FA_0, rm_idx] = ...
%      WINNOWFIRSTARRIVAL(filename, max_tres, max_twosd, min_snr, ph, rmsac)
%
% Winnows output of readfirstarrival.m based on input winnowing
% parameters.  E.g., use this to return a quality-controlled subset.
%
% See readfirstarrival.m for the meaning of the fields in FA.
%
% Input:
% filename     File name of file written by writefirstarrival.m
%                  (def: $MERMAID/.../firstarrival.txt)
% max_tres     QC parameter: tres(idx) <= max_tres (def; realmax)
% max_twosd    QC parameter: twosd(idx) <= max_twosd (def; realmax)
% min_snr      QC parameter: SNR(idx) >= max_twosd (def: realmin)
% ph           Cell of phase names to keep, e.g. {'p' 'P' 'PKP'},
%                  or 'all' to keep all phases (def: 'all)
% rmsac        Cell of any other SAC files to remove, for whatever reason
%
% Output:
% FA           Structure of winnowed first-arrival data
%                  s.t. isequaln(FA.s, FA_0.s(idx))
% idx          Indices that fall within winnowing criteria
% zerflag_idx  Indices of where zerflag is true
% perc         Percentage of data that make it through winnowing
% FA_0         Structure of complete (unwinnowed) first arrival data
% rm_idx       Indices removed (did not pass quality control)
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
% Last modified: 20-Mar-2020, Version 2017b on MACI64

% Defaults.
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrival.txt'))
defval('max_tres', realmax)
defval('max_twosd', realmax)
defval('min_snr', realmin)
defval('ph', 'all')
defval('rmsac', [])

high_tres = [];
high_twosd = [];
low_snr = [];

% Overwrite the variable name for the input phase list to differentiate it from
% the firstarrival phase list, read next.
ph2keep = ph;
clear('ph')

% Read the file.
[s, ph, dat, tres, tptime, tadj, delay, twosd, maxc_y, SNR, ID, winflag, tapflag, zerflag] = ...
    readfirstarrival(filename);

% Find parameters that pass quality criteria.  Here I chose to remove
% indices from the complete set all at once to avoid index clashes,
% but these logical expressions are equivalent to those (opposite
% ones) in the header because: a = randn(1,1e3); b = randn(1,1e3);
% isequal(a <= b, b > a) == isequal(a > b, b<=a)
high_tres = find(abs(tres) > max_tres);
high_twosd = find(twosd > max_twosd);
low_snr = find(SNR < min_snr);

% Find all NaN travel time residuals, signaling SNR <= 1 (i.e., low-SNR,
% by definition, in that the noise is bigger than the signal).
snr_leq1 = find(isnan(tres));

% Identify indices of sentinel values.
bad_win = find(winflag);
bad_tap = find(unzipnan(tapflag));
zerflag_idx = find(zerflag);

% Identify the indices other SAC which are marked for removal (by
% input request, not due to some quality criteria -- e.g., these could
% be the ones verified to be zero-filled after inspecting the true
% 'zerflag_idx').
%
% NB, I use cellstrfind and not, e.g., intersect, because the SAC
% files marked for removal may not have an otype (like 'none', or
% 'vel') appended, but the files loaded here may.  Therefore only a
% partial SAC filename match without is required (not met with
% intersect).
rmsac_idx = [];
for i = 1:length(rmsac)
    rmsac_idx(i)  = cellstrfind(s, rmsac(i));  % don't change -- we want partial matches

end
rmsac_idx = rmsac_idx(:);

% Concatenate all removals indices.
rm_idx = unique([high_tres ;
                 high_twosd ;
                 low_snr ;
                 snr_leq1 ;
                 bad_win ;
                 bad_tap ;
                 rmsac_idx]);


% The indices to keep are thus those with aren't slated for removal.
all_idx = 1:length(s);
idx = setdiff(all_idx, rm_idx);

% After removal of what we DON'T want, identify what we DO want.
if ~strcmpi(ph2keep, 'all')
    ph_idx = [];

    for i = 1:length(ph2keep)
        % NB, cannot use cellstrind here because we want exact matches.
        ph_idx = [ph_idx ; find(strcmp(ph, ph2keep{i}))];

    end
    % The final list is the intersection of idx (found by removing what we don't
    % want) and ph_idx (found by keeping what we do want).
    idx = intersect(idx, ph_idx);

    % Recompute the list of removed indices.
    rm_idx = setdiff(all_idx, idx)';

end

% Compute the percentage of data kept.
perc = (length(idx)/length(all_idx))*100;

% Log the complete, original data for inspection, maybe.
FA_0.filename = filename;
FA_0.s = s;
FA_0.ph = ph;
FA_0.dat = dat;
FA_0.tres = tres;
FA_0.tptime = tptime;
FA_0.tadj = tadj;
FA_0.delay = delay;
FA_0.twosd = twosd;
FA_0.maxc_y = maxc_y;
FA_0.SNR = SNR;
FA_0.ID = ID;
FA_0.winflag = winflag;
FA_0.tapflag = tapflag;
FA_0.zerflag = zerflag;

% Remove all incomplete cases.
FA.filename = filename;
FA.s = s(idx);
FA.ph = ph(idx);
FA.dat = dat(idx);
FA.tres = tres(idx);
FA.tptime = tptime(idx);
FA.tadj =  tadj(idx);
FA.delay =  delay(idx);
FA.twosd =  twosd(idx);
FA.maxc_y =  maxc_y(idx);
FA.SNR =  SNR(idx);
FA.ID =  ID(idx);
FA.winflag =  winflag(idx);
FA.tapflag =  tapflag(idx);
FA.zerflag =  zerflag(idx);
