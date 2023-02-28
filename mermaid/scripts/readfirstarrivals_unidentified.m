function MERMAID = readfirstarrivals_unidentified(filename)
% MERMAID = READFIRSTARRIVALS_UNIDENTIFIED(filename)
%
% Read output of `readfirstarrivals_unidentified`
%
% Input:
% filename  Filename
%           (default: $MERMAID/events/reviewed/unidentified/txt/firstarrivals_unidentified.txt)
%
% Output:
% MERMAID   Struct with columns as fieldnames
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
datadir = fullfile(merdir, 'events', 'reviewed', 'unidentified', 'txt');
defval('filename', fullfile(datadir, 'firstarrivals_unidentified.txt'));

sac_fmt = '%44s        ';                       %  1
sttime_fmt = '%22s        ';
stlo_fmt = '%9.4f        ';
stla_fmt = '%8.4f        ';
stdp_fmt = '%5f        ';                       %  5
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

fid = fopen(filename, 'r');
C = textscan(fid, fmt,  'HeaderLines', 2);

MERMAID.filename  = C{1};
MERMAID.seismogram_time = fdsnstr2date(C{2});
MERMAID.stlo = C{3}; % -180:180 longitude
MERMAID.stlo_360 = MERMAID.stlo;
MERMAID.stlo_360(MERMAID.stlo_360<0) = MERMAID.stlo(MERMAID.stlo_360<0) + 360; % 0:360 longitude
MERMAID.stla = C{4};
MERMAID.stdp = C{5};
MERMAID.ocpd = C{6};
MERMAID.obs_arvltime = C{7};
MERMAID.obs_arvltime_UTC = fdsnstr2date(C{8});
MERMAID.bathy_time_adj = C{9};
MERMAID.obs_arvltime_z0_UTC = fdsnstr2date(C{10});
MERMAID.twosd = C{11};

fclose(fid);
