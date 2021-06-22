function simon2021gji_1D_travtimediff
% SIMON2021gji_1D_TRAVTIMEDIFF
%
% THM: this proves Jessica and I compute the same 1D travel times (all diffs <= 1
% sampling interval) and all 1D epicentral distances within 0.005 degrees, which
% makes sense because it seems Jessica's TauP is only good to 2 decimal places
% (same as my terminal version), whereas mine are double precision, so 0.005 is
% the max diff you can have with 3-decimal place rounding.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');
datadir = fullfile(getenv('SIMON2020_CODE'), 'data');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)
close all

id_txtfile =  fullfile(evtdir, 'reviewed', 'identified', 'txt', 'identified.txt');
jds_filename = fullfile(datadir, 'mer.firstarr.all.txt');
[jds_sac, jds_ph, ~, ~, jds_1D_traveltime] =  readfirstarrival(jds_filename);

% Read llnl file, updated for automaid v3+ through 2019 for DET, non-core.
jcei_filename = strrep(id_txtfile, 'identified.txt', 'llnl.txt');
[jcei_sac, ~, jcei_1D_traveltime, ~, jcei_gcdiff, jcei_1D_gcarc, ~, jcei_ph] = readllnl(jcei_filename);

idx = ismember(jcei_sac, jds_sac);
jcei_sac = jcei_sac(idx);
jcei_1D_traveltime = jcei_1D_traveltime(idx);
jcei_gcdiff = jcei_gcdiff(idx);
jcei_1D_gcarc = jcei_1D_gcarc(idx);
jcei_ph = jcei_ph(idx);

% Sanity
if ~isequal(jcei_sac, jds_sac)
    error('indexing issue')

end

%% Let's first go down the line and identify largest 1D travel-time discrepancies.
%%______________________________________________________________________________________%%
traveltime_diff_1D = abs(jds_1D_traveltime - jcei_1D_traveltime);
[traveltime_diff_1D, idx] = sort(traveltime_diff_1D, 'descend');

jds_sac = jds_sac(idx);
jds_1D_traveltime = jds_1D_traveltime(idx);
jds_ph = jds_ph(idx);

jcei_sac = jcei_sac(idx);
jcei_1D_traveltime = jcei_1D_traveltime(idx);
jcei_gcdiff = jcei_gcdiff(idx);
jcei_1D_gcarc = jcei_1D_gcarc(idx);
jcei_ph = jcei_ph(idx);

if ~isequal(jcei_sac, jds_sac)
    error('indexing issue')

end

% Look at top five discrepancies: other than first two they are all within (or
% equal to) one sampling interval (0.05 s). The large first two correspond to
% Joel's phases of S and pP.
traveltime_diff_1D(1:5)
jds_ph(1:5)
jcei_ph(1:5)

%% THM:  everything is good to go; our 1D travel times agree.

% Let's look at 1D epicentral-distance differences.
for i = 1:length(jds_sac)
    EQ = getevt(jds_sac{i});
    diff(i) = EQ(1).TaupTimes(1).distance - jcei_1D_gcarc(i);

end
max(abs(diff))
