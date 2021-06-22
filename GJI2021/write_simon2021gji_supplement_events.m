function write_simon2021gji_supplement_events
% WRITE_SIMON2021GJI_SUPPLEMENT_EVENTS
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Preliminaries

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');
datadir = fullfile(getenv('GJI21_CODE'), 'data');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

% Nab all (identified and not) DET (non-'prelim') SAC files recorded through 2019.
evt2txt_fname = fullfile(evtdir, 'reviewed', 'all.txt');
endtime = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
s = readevt2txt(evt2txt_fname, [], endtime, 'DET', false);

% Ensure the SAC files are sorted.
tdate = mersac2date(s);
if ~issorted(tdate)
    sort_idx = sort(tdate, 'ascend');
    tdate = tdate(sort_idx);

end

% Specify formats.
sac_fmt = '%44s        ';

evtime_fmt = '%22s        ';
evlo_fmt = '%9.4f        ';
evla_fmt = '%8.4f        ';
magval_fmt = '%3.1f          ';
magtype_fmt = '%3s        ';
evdp_fmt = '%6i        ';

sttime_fmt = '%22s        ';
stlo_fmt = evlo_fmt;
stla_fmt = evla_fmt;
stdp_fmt = '%5i        ';
ocdp_fmt = stdp_fmt;

gcarc_1D_fmt = '%8.4f        ';

contrib_eventid_fmt = '%10s        ';
iris_eventid_fmt = '%8s';

fmt = [sac_fmt ...
       ... %
       evtime_fmt ...
       evlo_fmt ...
       evla_fmt ...
       magval_fmt ...
       magtype_fmt ...
       evdp_fmt ...
       .... %
       sttime_fmt ...
       stlo_fmt ...
       stla_fmt ...
       stdp_fmt ...
       ocdp_fmt ...
       ... %
       gcarc_1D_fmt ...
       ...
       contrib_eventid_fmt ...
       iris_eventid_fmt ...
       '\n'];


%%______________________________________________________________________________________%%

filename = fullfile(datadir, 'supplement', 'simon2021gji_supplement_events.txt');
writeaccess('unlock', filename);
fid = fopen(filename, 'w');

hdrline1 = 'COLUMN:                                    1                             2                3               4          5            6             7                             8                9              10           11           12              13                14              15';
hdrline2 = 'DESCRIPTION:                        FILENAME                    EVENT_TIME             EVLO            EVLA    MAG_VAL     MAG_TYPE          EVDP               SEISMOGRAM_TIME             STLO            STLA         STDP         OCDP        1D_GCARC           NEIC_ID         IRIS_ID';

fprintf(fid, '%s\n', hdrline1);
fprintf(fid, '%s\n', hdrline2);

for i = 1:length(s)
    % Retrieve the SAC header.
    sac = s{i};
    [~, h] = readsac(fullsac(sac, procdir));
    seisdate = seistime(h);
    sttime = fdsndate2str(seisdate.B);

    % Round seismogram time to 1/100 of s precision from millisecond-precision.
    % Don't just cut off the last sig fig because all other numbers are rounded,
    % and I specifically say all times are ROUNDED (not truncated) in the
    % supplement (not just 'floor'ed in the output text file; e.g., the travel
    % time residuals and their estimated uncertainties are rounded to 1/100 s).
    rounded_sttime_decimal = num2str(round(str2double(sttime(end-3:end)), 2));
    sttime(end) = []; % chop of 1/1000 s decimal place
    sttime(end) = rounded_sttime_decimal(end); % replace 1/100 s decimal place with rounded value

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

    %% Event info.

    evtime = NaN;
    evlo = NaN;
    evla = NaN;
    magval = NaN;
    magtype = NaN;
    evdp = NaN;
    gcarc_1D = NaN;
    contrib_eventid = NaN;
    iris_eventid = NaN;

    EQ = getevt(sac, evtdir);
    if ~isempty(EQ)
        EQ = EQ(1);

        % Parse event parameters.
        evtime_date = irisstr2date(EQ.PreferredTime);
        evtime = fdsndate2str(evtime_date);

        % Round event time as in seismogram time.
        rounded_evtime_decimal = num2str(round(str2double(evtime(end-3:end)), 2));
        evtime(end) = [];
        evtime(end) = rounded_evtime_decimal(end);

        evla = EQ.PreferredLatitude;
        evlo = EQ.PreferredLongitude;
        evdp_km = EQ.PreferredDepth;
        evdp = round(evdp_km * 1000);

        magval = EQ.PreferredMagnitudeValue;
        magtype = EQ.PreferredMagnitudeType;
        [contrib_eventid, ~, iris_eventid] = eventid(EQ);

        gcarc_1D = EQ.TaupTimes(1).distance;

    end

    %%______________________________________________________________________________________%%
    data = {strippath(sac) ...
            ... %
            evtime ...
            evlo ...
            evla ...
            magval ...
            magtype ...
            evdp ...
            ... %
            sttime ...
            stlo ...
            stla ...
            stdp ...
            ocdp ...
            ... %
            gcarc_1D ...
            contrib_eventid ...
            iris_eventid ...
           };

    fprintf(fid, fmt, data{:});

end
fclose(fid);
writeaccess('lock', filename);
