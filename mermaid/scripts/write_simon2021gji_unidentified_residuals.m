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
% Last modified: 24-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Preliminaries
clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
datadir = fullfile(merdir, 'events', 'reviewed', 'unidentified', 'txt');

% Parameters for firstarrival text file.
ci = true;
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

% Sort based on starttime
[~, sidx] = sort(mersac2date(s));
s = s(sidx);

% Specify formats                             Column
sac_fmt = '%44s        ';                       %  1
sttime_fmt = '%22s        ';
stlo_fmt = '%9.4f        ';
stla_fmt = '%8.4f        ';
stdp_fmt = '%5i        ';                       %  5
ocdp_fmt = stdp_fmt;
obs_arvltime_fmt = '%6.2f        ';
obs_arvltime_utc_fmt = sttime_fmt;
tadj_1D_fmt = '%5.2f        ';
obs_arvltime_utc_z0_fmt = obs_arvltime_utc_fmt; % 10
twosd_fmt = '%6.2f';                            % 11

fmt = [sac_fmt ...                        %  1
       sttime_fmt ...
       stlo_fmt ...
       stla_fmt ...
       stdp_fmt ...                       %  5
       ocdp_fmt ...
       obs_arvltime_fmt ...
       obs_arvltime_utc_fmt ...
       tadj_1D_fmt ....
       obs_arvltime_utc_z0_fmt ...        % 10
       twosd_fmt ...                      % 11
       '\n'];

% Define filename and header lines
filename = fullfile(datadir, 'simon2021gji_unidentified_residuals.txt');

hdrline1 = '#COLUMN:                                   1                             2                3               4            5            6             7                             8            9                            10            11';
hdrline2 = '#DESCRIPTION:                       FILENAME               SEISMOGRAM_TIME             STLO            STLA         STDP         OCDP  OBS_ARVLTIME      OBS_ARVLTIME_UTC(Z=STDP) 1D*_TIME_adj         OBS_ARVLTIME_UTC(Z=0)      2STD_ERR';

writeaccess('unlock', filename, false);
fid = fopen(filename, 'w');
fprintf(fid, '%s\n', hdrline1);
fprintf(fid, '%s\n', hdrline2);

% Loop over every unidentified SAC and write a line for each.
for i = 1:length(s);
    i
    % Retrieve the SAC header.
    sac = s{i};
    [~, h] = readsac(fullsac(s{i}, procdir));
    seisdate = seistime(h);
    sttime = round2decimal(fdsndate2str(seisdate.B));

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

    % These values (travel time residual and expected arrival time) are adjusted for
    % bathymetry and cruising depth because that is how I did it in the GJI paper.
    [~, obs_arvltime, ~, tadj_1D, ~, ~, twosd] ...
        = firstarrival_unidentified(sac, ci, wlen, lohi, procdir, bathy, wlen2, fs, popas, pt0);

    % UTC Datetime of observed arrival in seismogram
    % So this is the ACTUAL in REAL UTC time that MERMAID records the signal while at depth
    obs_arvltime_utc = seisdate.B + seconds(obs_arvltime) - pt0;
    if ~isnat(obs_arvltime_utc)
        obs_arvltime_utc_str = round2decimal(fdsndate2str(obs_arvltime_utc));

    else
        obs_arvltime_utc_str = NaN;

    end

    % UTC Datetime of arrival in seismogram as if it were observed at the surface
    % So this is a PROJECTED time in UTC by pretending MERMAID were on hard rock at Z=0
    % The bathymetric time correction must be REMOVED from the observed arrival time (see bathime.pdf)
    obs_arvltime_z0_utc = obs_arvltime_utc - seconds(tadj_1D);
    if ~isnat(obs_arvltime_z0_utc)
        obs_arvltime_utc_z0_str = round2decimal(fdsndate2str(obs_arvltime_z0_utc));

    else
        obs_arvltime_utc_z0_str = NaN;

    end

    % Organize and write output line by line
    data = {strippath(sac) ...            %  1
            sttime ...
            stlo ...
            stla ...
            stdp ...                      %  5
            ocdp ...
            obs_arvltime ...
            obs_arvltime_utc_str ...
            tadj_1D ...
            obs_arvltime_utc_z0_str ...   % 10
            twosd};                       % 11

    fprintf(fid, fmt, data{:});

end
fclose(fid);
writeaccess('lock', filename);

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
