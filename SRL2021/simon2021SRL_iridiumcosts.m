function simon2021SRL_iridiumcosts
% SIMON2021SRL_IRIDIUMCOSTS
%
% Estimates the cost to transmit one year of MERMAID data via Iridium.
%
% See $SRL21_CODE/data/iridium_bill.pdf for numbers this uses.
%
% Developed as: simon2021_iridiumcosts.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 04-May-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');

% Use 'master' branch  because 'GJI21' did not include all Mar 2021 data.
startdir = pwd;
cd(procdir)
system('git checkout master');
cd(startdir)

% From 'iridium_bill.pdf'
rudics_per_min_qty  = 1235.99;
rudics_per_min_cost = 0.650;
rudics_tot_cost = rudics_per_min_qty * rudics_per_min_cost;

s = fullsac([], procdir);
mar_2021 = datetime('01-Mar-2021', 'TimeZone', 'UTC');
apr_2021 = datetime('01-Apr-2021', 'TimeZone', 'UTC');

mer_seis = [];
mer_secs = 0;
for i = 1:length(s)
    % Preliminary SAC files are made by automaid and most often end up being
    % redundant to final SAC files.
    if contains(s{i}, 'prelim')
        continue

    end

    % Estimate the transmission date from the .MER filename
    % This is not exact due to dives cross month boundaries, but...good enough
    mer_idx = strfind(s{i}, 'MER');
    mer_name = s{i}(mer_idx-12:mer_idx+2);

    [~, trans_datestr] = system(sprintf('merlog2date %s', mer_name));
    trans_datetime = iso8601str2date(trans_datestr, 1);

    % Keep running tally of time and list of SAC file names if transmitted in March.
    if isbetween(trans_datetime, mar_2021, apr_2021)
        [~, h] = readsac(fullsac(s{i}, procdir));
        seis_datetime = seistime(h);
        seis_len_secs = seconds(seis_datetime.E - seis_datetime.B);

        mer_secs = mer_secs + seis_len_secs;
        mer_seis = [mer_seis ; s{i}];

    end
end

% Generate some stat printouts.
mer_mins = mer_secs / 60;
rudics_min_per_mer_min = rudics_per_min_qty / mer_mins;
rudics_cost_per_mer_min = rudics_min_per_mer_min * rudics_per_min_cost;

fprintf('Rudics transmission minutes: %.2f\n',  rudics_per_min_qty)
fprintf('MERMAID seismogram minutes transmitted %.2f\n', mer_mins)
fprintf('Rudics minutes (or years) required to transmit one MERMAID seismogram minute (or year) %.2f\n', rudics_min_per_mer_min);
fprintf('Cost to transmit one MERMAID seismogram minute: %.2f\n', rudics_cost_per_mer_min)
fprintf('Cost to transmit one MERMAID seismogram year: %i\n', round(rudics_cost_per_mer_min * 60 * 24 * 365))
