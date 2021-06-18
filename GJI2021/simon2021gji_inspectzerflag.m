function simon2021gji_inspectzerflag
% SIMON2021GJI_INSPECTZERFLAG
%
% Unaffected by otype because only the RAW SAC files see the contiguous zeros
% (once you deconvolve you add non-zero noise).  So .none and .vel have the same
% files marked for removal.
%
% Look at the CPPT stations with true zerflag to remove those traces
% which were zero-filled around the time of the first arrival.
%
% NEARBY stations had their data zero-filled ('.merged.' files), but those are
% ignored in write_simon2021gji_firstarrival_trad_rasp.m in favor of looking at
% the individual, unmerged files in the child unmerged/ subdirectory.
%
% For wlen = 30, lohi = [1 5], wlen2 = [1.75]:
%
% s = {'2018.231.1913.00.VAH.CPZ1.SHZ.SAC' ... % Pass
%      '2018.269.0037.00.TVO.CPZ1.SHZ.SAC' ... % !! Fail !!
%      '2018.298.1834.00.RKT.CPZ1.SHZ.SAC' ... % !! Fail !!
%      '2018.316.1754.00.VAH.CPZ1.SHZ.SAC' ... % !! Fail !!
%      '2019.267.0718.00.PAE.CPZ1.SHZ.SAC' ... % !! Fail !!
%      '2019.348.0500.00.TBI.CPZ1.SHZ.SAC'}    % Pass
%
% Developed as: simon2020_inspectzerflag.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Jun-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');
cpptdir = fullfile(evtdir, 'cpptstations');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

wlen = 30
lohi = [1 5]
bathy = false % no correction for bathymetry/cruising depth warranted for isLAND stations
wlen2 = 1.75

% ONLY THE RAW SAC FILES SHOW THE CONTIGUOUS ZEROS -- a complementary raw (no
% 'otype') file is written for the CPPT data.
datadir = fullfile(getenv('GJI21_CODE'), 'data');
cppt_det_raw = fullfile(datadir, 'nearby_and_cppt', 'cppt.firstarrpress.P..txt');
[s, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, zerflag_idx] = ...
    readfirstarrivalpressure(cppt_det_raw);

% These are the SAC files which contain at least two contiguous zeros with a
% firstarrival.m taper.
s = s(find(zerflag_idx))

cppt_sacdir = fullfile(cpptdir, 'sac')
cppt_evtdir = fullfile(cpptdir, 'evt')

for i = 1:length(s)
    [sac, EQ] = fullsacevt(s{i}, cppt_sacdir, cppt_evtdir);

    figure
    [x, h] = readsac(sac);
    xax = xaxis(h.NPTS, h.DELTA, h.B);
    plot(xax, x);

    % The full taper is double the window length, so look left/right the
    % complete window length (even though the pick is only made in the
    % middle section, 1 window length-long).
    vertline(EQ(1).TaupTimes(1).truearsecs - wlen, [], 'k');
    vertline(EQ(1).TaupTimes(1).truearsecs);
    vertline(EQ(1).TaupTimes(1).truearsecs + wlen, [], 'k');

    keyboard
    close all

end
