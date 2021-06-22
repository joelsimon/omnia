function simon2021gji_vs_bbobs_plume(winnowed_dataset)
% SIMON2021GJI_VS_BBOBS_PLUME(winnowed_dataset)
%
% Compares MERMAID residuals statistics against BBOBS and PLUME using M5.5+
% and 30 < distance < 100 degreess (as is done there).
%
% If `winnowed_dataset` is true then only 3D residuals which made their into
% the darker stacked histogram of Fig. 11(f) are used: 3D residuals within +-
% 10 s, max. twosd uncertainty of 0.15 s.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

defval('winnowed_dataset', true)

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)


% Read first-arrival p or P wave file.
res_filename = fullfile(getenv('GJI21_CODE'), 'data', 'supplement', 'simon2021gji_supplement_residuals.txt');
MER = read_simon2021gji_supplement_residuals(res_filename);

% Only keep EQs with magnitudes greater than 5.5 and between 30 and 100 degrees.
rm_mag_idx = find(MER.mag_val < 5.5);
MER = rmstructindex(MER, rm_mag_idx);

rm_dist_idx = find(MER.gcarc_1D < 30 | MER.gcarc_1D > 100);
MER = rmstructindex(MER, rm_dist_idx);

if winnowed_dataset
    max_tres = 10; % s
    max_twosd = 0.15; % s

    high_twosd = find(MER.twosd > max_twosd);
    high_tres = find(abs(MER.tres_3D > max_tres));

    % The total number of residuals retained should equal the number of residuls in
    % the darker stacked histogram of Fig. 11(f) (of which, not all may be
    % plotted due to the x-axis limits).
    MER = rmstructindex(MER, union(high_twosd, high_tres));

end


%histogram(MER.mag_val);
%histogram(MER.gcarc_1D);

% Collect MERMAID stats.
mer_res = length(MER.filename);
mer_instr = 16;
mer_evt = length(unique(MER.IRIS_ID));
mer_yr = years(datetime('01-Jan-2020') - datetime('29-Aug-2018'));

%% ___________________________________________________________________________ %%
%%               BBOBS and PLUME (Suetsugu+2009; Tanaka+2009a)                 %%
%% ___________________________________________________________________________ %%

bbobs_res = 1477;
bbobs_instr = 23; % 10 BBOBS, 10 PLUME + PPT, PTCN, RAR
bbobs_evt = 121;
bbobs_yr = 22/12; % years; period 1: 12 months; period 2: 10 months

% Factors always BBOBS over MERMAID.
instr_factor = bbobs_instr/mer_instr;
fprintf('MERMAID: %i instruments\n', mer_instr)
fprintf('  BBOBS: %i instruments\n', bbobs_instr)
fprintf('Instrument factor: %.2f\n\n', instr_factor)

yr_factor = bbobs_yr/mer_yr;
fprintf('MERMAID: %.2f years deployed\n', mer_yr)
fprintf('  BBOBS: %.2f years deployed\n', bbobs_yr)
fprintf('Deployement factor: %.2f\n\n', yr_factor)

evt_factor = bbobs_evt/mer_evt;
fprintf('MERMAID: %3i unique events\n', mer_evt)
fprintf('  BBOBS: %3i unique events\n', bbobs_evt)
fprintf('Total events factor: %.2f\n\n', evt_factor)

res_factor = bbobs_res/mer_res;
fprintf('MERMAID: %4i residuals\n', mer_res)
fprintf('  BBOBS: %4i residuals\n', bbobs_res)
fprintf('Total residuals factor: %.2f\n\n', res_factor)

mer_res_instr_yr = mer_res/mer_instr/mer_yr;
bbobs_res_instr_yr = bbobs_res/bbobs_instr/bbobs_yr;
res_instr_yr_factor = bbobs_res_instr_yr/mer_res_instr_yr;
fprintf('MERMAID: %.2f residuals reported by each instrument each year\n', mer_res_instr_yr)
fprintf('  BBOBS: %.2f residuals reported by each instrument each year\n', bbobs_res_instr_yr)
fprintf('Residuals reported by each instrument every year factor: %.2f\n\n', res_instr_yr_factor)

%(instr_factor*yr_factor*res_instr_yr_factor) == res_factor
