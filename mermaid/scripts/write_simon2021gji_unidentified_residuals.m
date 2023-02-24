function write_simon2021gji_unidentified_residuals
% WRITE_SIMON2021GJI_UNIDENTIFIED_RESIDUALS
%
% Writes "arrival times" of the observed "P" wave in unidentified events in the
% same general format (similar column names are defined identically) as the real
% residuals (identified events) in the online supplement my 2022 GJI paper:
%
%    @Article{Simon+2022,
%      author =	 {Joel D. Simon and Frederik J. Simons and Jessica C. E. Irving},
%      title =	 {Recording earthquakes for tomographic imaging of the mantle
%                      beneath the {South} {Pacific} by autonomous {MERMAID} floats},
%      year =	 2022,
%      journal =	 GJI,
%      volume =	 228,
%      number =	 1,
%      pages =	 {147--170, 10.1093/gji/ggab271}
%    }
%
% So this script name is a bit of misnomer because I don't actually print
% residuals because there is no theoretical time against which to compute them
% (I just set my 30 second window at 100 seconds as a starting point to refine
% my pick)...
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Feb-2023, Version 9.3.0.948333 (R201b7) Update 9 on MACI64

llnl_exists = false;

%% Preliminaries
clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
datadir = fullfile(merdir, 'events', 'reviewed', 'unidentified', 'txt');

% Parameters for firstarrival text file.
%ci = false; % Load pre-computed confidence intervals from firstarrival txt file.
ci = true; % Remake confidence intervals using a new call to `firstarrivals`
wlen = 30;
lohi = [1 5];
bathy = true;
wlen2 = [1.75];
fs = 20; % Decimation is a pass-through function when R = 1 (which it does at fs = 20).
popas = [4 1];
pt0 = 0;

% Load all unidentified DET files.
s = revsac(-1, procdir, [], 'DET');

% Remove glitchy .sac files
glitch_sac = bumps;
s = setdiff(s, glitch_sac);

%%              Compute 1D ADJUSTED travel times and remove adjustment                  %%
%%______________________________________________________________________________________%%
%%______________________________________________________________________________________%%
%%______________________________________________________________________________________%%

% Specify formats.
sac_fmt = '%44s        ';                 %  1

evtime_fmt = '%22s        ';
evlo_fmt = '%9.4f        ';
evla_fmt = '%8.4f        ';
magval_fmt = '%3.1f          ';           %  5
magtype_fmt = '%3s        ';
evdp_fmt = '%6i        ';

sttime_fmt = '%22s        ';
stlo_fmt = evlo_fmt;
stla_fmt = evla_fmt;                      % 10
stdp_fmt = '%5i        ';
ocdp_fmt = stdp_fmt;

gcarc_1D_fmt = '%7.4f        ';
gcarc_1Dadj_diff_fmt = '%6i        ';
gcarc_1Dadj_fmt = gcarc_1D_fmt;           % 15
gcarc_3D_diff_fmt = '%7.4f        ';
gcarc_3D_fmt = gcarc_1D_fmt;

obs_travtime_fmt = '%6.2f        ';
obs_arvltime_fmt = obs_travtime_fmt;
obs_arvltime_utc_fmt = sttime_fmt;

exp_travtime_1D_fmt = '%7.2f        ';    % 20
exp_arvltime_1D_fmt = '%6.2f        ';
tres_1D_fmt = exp_arvltime_1D_fmt;

tadj_1D_fmt = '%5.2f        ';
exp_travtime_1Dadj_fmt = '%7.2f        ';
exp_arvltime_1Dadj_fmt = '%6.2f        '; % 25
tres_1Dadj_fmt = '%6.2f        ';

tadj_3D_fmt = '%5.2f        ';
exp_travtime_3D_fmt = '%7.2f        ';
exp_arvltime_3D_fmt = '%6.2f        ';
tres_3D_fmt = '%6.2f        ';            % 30

twosd_fmt = '%6.2f        ';
SNR_fmt= '%6u        ';
max_counts_fmt = '%9i        ';
max_delay_fmt = '%4.2f        ';

contrib_eventid_fmt = '%10s        ';     % 35
iris_eventid_fmt = '%8s';                 % 36

fmt = [sac_fmt ...                        %  1
       ... %
       sttime_fmt ...
       stlo_fmt ...
       stla_fmt ...                       % 10
       stdp_fmt ...
       ocdp_fmt ...
       ... %
       obs_arvltime_fmt ...
       obs_arvltime_utc_fmt ...
       ... %
       tadj_1D_fmt ....
       ... %
       twosd_fmt ...
       SNR_fmt ...
       max_counts_fmt ...
       max_delay_fmt ...
       '\n'];


%%______________________________________________________________________________________%%


filename = fullfile(datadir, 'simon2021gji_unidentified_residuals.txt');

hdrline1 = '#COLUMN:                                   1                             2                3               4            5            6             7                             8            9            10            11               12          13';
hdrline2 = '#DESCRIPTION:                       FILENAME               SEISMOGRAM_TIME             STLO            STLA         STDP         OCDP  OBS_ARVLTIME              OBS_ARVLTIME_UTC 1D*_TIME_adj      2STD_ERR           SNR       MAX_COUNTS    MAX_TIME';

writeaccess('unlock', filename, false);
fid = fopen(filename, 'w');
fprintf(fid, '%s\n', hdrline1);
fprintf(fid, '%s\n', hdrline2);

max_tdiff_check = 0; % for testing
                     %for i = 1:length(s);
for i =1:5
    i
    % Retrieve the SAC header.
    sac = s{i};
    [~, h] = readsac(fullsac(s{i}, procdir));
    seisdate = seistime(h);
    sttime = fdsndate2str(seisdate.B);
    sttime = round2decimal(sttime);

    % Parse station parameters.
    % Station depth is in meters, down is positive.
    stdp = h.STDP;
    if stdp == -12345
        stdp = NaN;

    end
    stla = h.STLA;
    stlo = h.STLO;

    % Ocean depth according to GEBCO 2014 at recording location of SAC file.
    % Flip the sign so that down is positive.
    ocdp = gebco(stlo, stla, '2014');
    ocdp = -ocdp;

    %%______________________________________________________________________________________%%

    % These values (travel time residual and expected arrival time) are adjusted for
    % bathymetry and cruising depth because that is how I did it in the GJI paper.
    [~, obs_arvltime, ~, tadj_1D, ~, max_delay, twosd, ~, ~, ~, max_counts, SNR] = ...
        firstarrival_unidentified(sac, ci, wlen, lohi, procdir, bathy, wlen2, fs, popas, pt0);

    % UTC Datetime of actual observed arrival in seismogram (so, observed at depth).
    obs_arvltime_utc = seisdate.B + seconds(obs_arvltime) - pt0;;
    if ~isnat(obs_arvltime_utc)
        obs_arvltime_utc = fdsndate2str(obs_arvltime_utc);
        obs_arvltime_utc = round2decimal(obs_arvltime_utc)

    end

    % Round the SNR; when its down in single digits is so low who cares if
    % its rounded.
    SNR = round(SNR);

    % The max. counts are non-integer due to filtering; round them because it's
    % meaningless to have a fractional count.
    max_counts = round(max_counts);

    %%______________________________________________________________________________________%%
    data = {strippath(sac) ...
            ... %
            sttime ...
            stlo ...
            stla ...
            stdp ...
            ocdp ...
            ... %
            obs_arvltime ...
            obs_arvltime_utc ...
            ... %
            tadj_1D ...
            ... %
            twosd ...
            SNR ...
            max_counts ...
            max_delay};

    fprintf(fid, fmt, data{:});

end
fclose(fid);
%writeaccess('lock', filename);

%% ___________________________________________________________________________ %%

function t = round2decimal(t)

% Round times time to 1/100 of s precision from millisecond-precision.  Don't
% just cut off the last sig fig because all other numbers are rounded, and I
% specifically say all times are ROUNDED (not truncated) in the supplement (not
% just 'floor'ed in the output text file; e.g., the travel time residuals and
% their estimated uncertainties are rounded to 1/100 s).

rounded_t_decimal = num2str(round(str2double(t(end-3:end)), 2));
t(end) = []; % chop of 1/1000 s decimal place
t(end) = rounded_t_decimal(end); % replace 1/100 s decimal place with rounded value














        