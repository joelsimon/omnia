function write_tomocat1(redo, procdir, evtdir, txtdir, revtxt)
% WRITE_TOMOCAT1(redo, procdir, evtdir, txtdir, revtxt)
%
% Tomography Catalog Iteration #1: GJI22 supplement + KSTNM, REVIEWER
%
% Input:
% redo        true to delete and remake existing tomocat1.txt (def: true)
% procdir     Processed directory (def: $MERMAID/processed_everyone/)
% evtdir      Events directory (def: $MERMAID/events_everyone/)
% txtdir      Textfile directory (def: $MERMAID/events_everyone/reviewed/identified/txt)
% revtxt      Reviewer textfile (def: [])
%
% Output:
% tomocat1.txt
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 12-Nov-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

clc
close all
llnl_exists = false;

% Joel D. Simon (JDS; Princeton) : 1
% Yong Yu (YY; SUSTech)          : 2
% Dalija Namjesnik (DN; GeoAzur) : 3
% Yuko Kondo (YK; Kobe)          : 4
% JDS and YY                     : 5
% JDS and DN                     : 6
% JDS and YK                     : 7

defval('redo', true)
defval('procdir', fullfile(getenv('MERMAID'), 'processed_everyone'));
defval('evtdir',  fullfile(getenv('MERMAID'), 'events_everyone'));
defval('txtdir', fullfile(getenv('MERMAID'), 'events_everyone', 'reviewed', 'identified', 'txt'));
defval('revtxt', [])

%% Preliminaries

% Parameters for firstarrival text file.
ci = true; % Remake confidence intervals using a new call to `firstarrivals`
wlen = 30;
lohi = [1 5];
bathy = true;
wlen2 = [1.75];
fs = 20; % Decimation is a pass-through function when R = 1 (which it does at fs = 20).
popas = [4 1];
pt0 = 0;

% P phases we are interested in (keep PKiKP as option because that may have been
% the first-arriving phase saved in the time of the seismogram, despite the
% later-arriving PKP being the actual pick; we will adjust window to prioritize
% the PKP pick).
p_phases = {'p' 'P' 'PKIKP' 'PKP' 'PKiKP'};

%%            Identify the list of SAC files whose first phase is p or P                %%
%%______________________________________________________________________________________%%

% Read the relevant SAC files from mer.firstarr.all.txt.
mer_det_txt1 = fullfile(txtdir, 'firstarrival.txt');

% Use winnowfirstarrival.m because we only want p or P waves AND we don't want
% any with true win/zerflags.
FA = winnowfirstarrival(mer_det_txt1, [], [], [], p_phases);

% Remove REQ files.
req_idx = cellstrfind(FA.s, 'REQ');
FA = rmstructindex(FA, req_idx, {'filename'});

%% With update we want to remake these uncertainties; the uncertainties in the
%% firstarrival file may have been generated using different parameters/window
%% lengths
% Keep the twosd uncertainties so that they match those quoted in paper (these
% are random values so they do fluctuate somewhat).
% twosd_vector = FA.twosd;

% Read Jessica's LLNL text file.
if llnl_exists
    llnl_txt = fullfile(evtdir, 'reviewed', 'identified', 'txt', 'llnl.txt');
    LL = winnowllnl(llnl_txt, mer_det_txt1, [], [], [], p_phases);

    % Now the lists are the same
    if ~isequal(FA.s, LL.s)
        error('SAC indexing is screwed up')

    end

    % Keep only Jessica's 3D travel time, 3D distance (constructed using the
    % difference against HER 1D gcarc distance, which is lower precision (2 sig
    % figs) than mine (3 sig figs)), and station-side water correction (not applied
    % because we know MERMAID in water), and ditch everything else because I want to
    % use my numbers for things like distances because TauP, especially, varies
    % between platforms.
    exp_travtime_3D_vector = LL.d3_tptime;
    gcarc_3D_vector = LL.d1gc + LL.gcdiff;
    % watercorr = LL.watercorr;

else
    exp_travtime_3D_vector = NaN(size(FA.s));
    gcarc_3D_vector = NaN(size(FA.s));

end
s = FA.s;

% Let's just delete this old (who knows what parameters) `firstarrivals`
% output; use it only to determine which SAC files we need to inspect.
clearvars FA

% Load list of who reviewed what.
reviewer = [];
if ~isempty(revtxt)
    reviewer = readtext(revtxt);
    reviewer = strrep(reviewer, 'evt', 'sac');
end

%%              Compute 1D ADJUSTED travel times and remove adjustment                  %%
%%______________________________________________________________________________________%%
%%______________________________________________________________________________________%%
%%______________________________________________________________________________________%%

% Specify formats.
sac_fmt = '%46s        ';                 %  1

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

gcarc_1D_fmt = '%8.4f        ';
gcarc_1Dadj_diff_fmt = '%6i        ';
gcarc_1Dadj_fmt = gcarc_1D_fmt;           % 15
gcarc_3D_diff_fmt = '%7.4f        ';
gcarc_3D_fmt = gcarc_1D_fmt;

obs_travtime_fmt = '%7.2f        ';
obs_arvltime_fmt = obs_travtime_fmt;

exp_travtime_1D_fmt = '%7.2f        ';    % 20
exp_arvltime_1D_fmt = '%6.2f        ';
tres_1D_fmt = exp_arvltime_1D_fmt;

tadj_1D_fmt = '%6.2f        ';
exp_travtime_1Dadj_fmt = '%7.2f        ';
exp_arvltime_1Dadj_fmt = '%6.2f        '; % 25
tres_1Dadj_fmt = '%6.2f        ';

tadj_3D_fmt = '%6.2f        ';
exp_travtime_3D_fmt = '%7.2f        ';
exp_arvltime_3D_fmt = '%6.2f        ';
tres_3D_fmt = '%6.2f        ';            % 30

twosd_fmt = '%6.2f        ';
SNR_fmt= '%8u        ';
max_counts_fmt = '%15i        ';
max_delay_fmt = '%4.2f        ';

contrib_eventid_fmt = '%14s        ';     % 35
iris_eventid_fmt = '%8s       ';          % 36

kstnm_fmt = '%5s        ';                % 37
phase_fmt = '%5s        ';
reviewer_fmt = '%2i';                     % 39

fmt = [sac_fmt ...                        %  1
       ... %
       evtime_fmt ...
       evlo_fmt ...
       evla_fmt ...
       magval_fmt ...                     %  5
       magtype_fmt ...
       evdp_fmt ...
       .... %
       sttime_fmt ...
       stlo_fmt ...
       stla_fmt ...                       % 10
       stdp_fmt ...
       ocdp_fmt ...
       ... %
       gcarc_1D_fmt ...
       gcarc_1Dadj_diff_fmt ...
       gcarc_1Dadj_fmt ...                % 15
       gcarc_3D_diff_fmt ...
       gcarc_3D_fmt ...
       ...
       obs_travtime_fmt ...
       obs_arvltime_fmt ...
       ... %
       exp_travtime_1D_fmt ...            % 20
       exp_arvltime_1D_fmt ...
       tres_1D_fmt ...
       ... %
       tadj_1D_fmt ....
       exp_travtime_1Dadj_fmt ...
       exp_arvltime_1Dadj_fmt ...         % 25
       tres_1Dadj_fmt ...
       ... %
       tadj_3D_fmt ...
       exp_travtime_3D_fmt ...
       exp_arvltime_3D_fmt ...
       tres_3D_fmt ...                    % 30
       ... %
       twosd_fmt ...
       SNR_fmt ...
       max_counts_fmt ...
       max_delay_fmt ...
       ...
       contrib_eventid_fmt ...             % 35
       iris_eventid_fmt ...                % 36
       ...
       kstnm_fmt, ...                      % 37
       phase_fmt, ...
       reviewer_fmt, ...                   % 39
       '\n'];


%%______________________________________________________________________________________%%

filename = fullfile(txtdir, 'tomocat1.txt');

writeaccess('unlock', filename, false);
prev_file = exist(filename, 'file') == 2;

if ~prev_file || redo
    fid = fopen(filename, 'w+');
    hdrline1 = '#COLUMN:                                     1                              2                3               4          5            6             7                              8                9              10           11           12              13            14              15             16              17             18             19             20            21            22            23             24            25            26            27             28            29            30            31              32                     33          34                    35              36          37           38        39';
    hdrline2 = '#DESCRIPTION                          FILENAME                     EVENT_TIME             EVLO            EVLA    MAG_VAL     MAG_TYPE          EVDP                SEISMOGRAM_TIME             STLO            STLA         STDP         OCDP        1D_GCARC 1D*_GCARC_adj       1D*_GCARC   3D_GCARC_adj        3D_GCARC   OBS_TRAVTIME   OBS_ARVLTIME    1D_TRAVTIME   1D_ARVLTIME       1D_TRES  1D*_TIME_adj   1D*_TRAVTIME  1D*_ARVLTIME      1D*_TRES   3D_TIME_adj    3D_TRAVTIME   3D_ARVLTIME       3D_TRES      2STD_ERR             SNR             MAX_COUNTS    MAX_TIME               NEIC_ID         IRIS_ID       KSTNM        PHASE  REVIEWER';
    fprintf(fid, '%s\n', hdrline1);
    fprintf(fid, '%s\n', hdrline2);
    prev_mer = '';

else
    fid = fopen(filename, 'a');
    prev_mer = read_tomocat1(filename);

end

max_tdiff = 0;
max_tdiff_sac = '';
for i = 1:length(s);
    fprintf('Working on # %i of %i\n', i, length(s))
    sac = s{i};
    if ~redo && any(contains(prev_mer.filename, sac));
        continue

    end

    % Retrieve the SAC info.
    % Round seismogram time to centisecond precision from millisecond-precision.
    % Don't just cut off the last sig fig because all other numbers are rounded,
    % and I specifically say all times are ROUNDED (not truncated) in the
    % supplement (not just 'floor'ed in the output text file; e.g., the travel
    % time residuals and their estimated uncertainties are rounded to 1/100 s).
    [~, h] = readsac(fullsac(s{i}, procdir));
    seisdate = seistime(h);
    sttime = roundmsec(fdsndate2str(seisdate.B));
    kstnm = h.KSTNM;

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

    % Retrieve event structure.
    EQ = getrevevt(sac, evtdir);
    EQ = EQ(1);

    % In cases where inner and outer core phases (possibly) coexist we want to prioritize outer core phases.
    EQ = onlyPKP(EQ);
    phase_name = EQ.TaupTimes(1).phaseName;

    % Parse event parameters and round times as above.
    evtime_date = irisstr2date(EQ.PreferredTime);
    evtime = roundmsec(fdsndate2str(evtime_date));

    evla = EQ.PreferredLatitude;
    evlo = EQ.PreferredLongitude;
    evdp_km = EQ.PreferredDepth;
    evdp = round(evdp_km * 1000);

    magval = EQ.PreferredMagnitudeValue;
    magtype = EQ.PreferredMagnitudeType;
    [contrib_eventid, ~, iris_eventid] = eventid(EQ);

    %% Distance adjustments
    % Compute the 3D-1D epicentral distance difference (in degrees) using MY 1D
    % epicentral distance s.t. the textile may be properly summed with the
    % specific adjustments.  This explains why there are differences between my
    % 3D_GCARC_adj (what Jessica call 'gcdiff' in llnl.txt) in the 3rd (and
    % maybe even 2nd, with rounding) decimal place.  Basically I take her 3D
    % distance as truth and disregard her 1D distance, preferring instead to use
    % my own higher-precision number to compute their difference.
    gcarc_1D = EQ.TaupTimes(1).distance;
    gcarc_1Dadj = gcarc_1D;
    gcarc_3D = gcarc_3D_vector(i);

    gcarc_1Dadj_diff = gcarc_1Dadj - gcarc_1D;
    gcarc_3D_diff = gcarc_3D - gcarc_1D;

    %%         Times: adjusted for bathymetry and cruising depth; pt0 = 0 s
    %%______________________________________________________________________________________%%

    % These values (travel time residual and expected arrival time) are adjusted for
    % bathymetry and cruising depth because that is how I did it in the GJI paper.
    [tres_1Dadj, obs_arvltime, exp_arvltime_1Dadj, exp_arvltime_1Dadj_diff, ...
     ~, max_delay, twosd, ~, ~, ~, max_counts, SNR] = firstarrival(sac, ci, wlen, ...
                                                      lohi, procdir, ...
                                                      evtdir, EQ, bathy, ...
                                                      wlen2, fs, popas, pt0);

    if isnan(tres_1Dadj)
        continue

    end

    % The travel time and arrival time time-adjustments (tadj) are equal because the
    % time elapsed between the event and the start of the seismogram is the same
    % in both cases and cancels.
    exp_travtime_1Dadj_diff  = exp_arvltime_1Dadj_diff;

    % Round the SNR; when its down in single digits is so low who cares if it's rounded.
    SNR = round(SNR);

    % The max. counts are non-integer due to filtering; round them because it's
    % meaningless to have a fractional count.
    max_counts = round(max_counts);

    %%______________________________________________________________________________________%%

    % Absolute travel times (s)
    exp_travtime_1D = EQ.TaupTimes(1).time;
    exp_travtime_1Dadj = exp_travtime_1D + exp_travtime_1Dadj_diff;
    exp_travtime_3D = exp_travtime_3D_vector(i);

    % Travel time differences w.r.t. to ak135 (s)
    %    exp_travtime_1Dadj_diff = (self)
    exp_travtime_3D_diff = exp_travtime_3D - exp_travtime_1D;

    %% Call these diffs the 1-D and 3-D time adjustments (being very verbose here for clarity).
    tadj_1D = exp_travtime_1Dadj_diff;
    tadj_3D = exp_travtime_3D_diff;

    % Arrival time differences are equal to travel time differences; time between
    % event and seismogram are the same in all cases and cancel.
    %    exp_arvltime_1Dadj_diff = (self)
    exp_arvltime_3D_diff = exp_travtime_3D_diff;

    % Absolute arrival times (s)
    exp_arvltime_1D = exp_arvltime_1Dadj - exp_arvltime_1Dadj_diff;
    %    exp_arvltime_1Dadj = (self)
    exp_arvltime_3D = exp_arvltime_1D + exp_arvltime_3D_diff;

    % Absolute travel time residuals (s).
    tres_1D = obs_arvltime - exp_arvltime_1D;
    %    tres_1Dadj = (self)
    tres_3D  = obs_arvltime - exp_arvltime_3D;

    % No h.B adjustment is required because now `pt0=0` s, so the observed arrival
    % time is seconds into the seismogram starting at 0 seconds; therefore we
    % may add the seconds into the seismogram to the absolute starttime of the
    % the seismogram to get the absolute (in UTC) observed arrivaltime.
    obs_travtime = seconds((seisdate.B + seconds(obs_arvltime)) - evtime_date);

    % EQ.TaupTimes theoretical (expected) phase-arrival times are computed on an
    % x-axis whose pt0 is not 0 but rather h.B.  Therefore, use this as a final
    % check that the expected arrival time I computed from `firstarrivals`
    % (using `pt0=0`) matches that in the EQ structure on a different
    % x-axis. This just verifies that I get the same answer from two different
    % directions, and most all other numbers are based off this 1D time so if
    % it's good, it follows that all others should be valid.
    tdiff_check = (EQ(1).TaupTimes(1).truearsecs - EQ(1).TaupTimes(1).pt0) - exp_arvltime_1D;
    if tdiff_check > 1e-7 % s
        error('pt0-timing issue')

    end
    if abs(tdiff_check) > abs(max_tdiff)
        max_tdiff = tdiff_check;
        max_tdiff_sac = sac;

    end

    % Label the reviewer, if external 'reviewer.txt' file supplied.
    if ~isempty(reviewer)
        rviewr_idx = cellstrfind(reviewer, sac);
        if isempty(rviewr_idx)
            error('%s not found in %s (reviewer file)', strippath(sac), revtxt)

        end
        rviewr = str2num(strtrim(fx(strsplit(reviewer{rviewr_idx}, ','), 2)));

    else
        % Undetermined/unlabeled reviewer.
        rviewr = 0;

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
            gcarc_1Dadj_diff ...
            gcarc_1Dadj ...
            gcarc_3D_diff ...
            gcarc_3D ...
            ... %
            obs_travtime ...
            obs_arvltime ...
            ... %
            exp_travtime_1D ...
            exp_arvltime_1D ...
            tres_1D ...
            ... %
            tadj_1D ...
            exp_travtime_1Dadj ...
            exp_arvltime_1Dadj ...
            tres_1Dadj ...
            ... %
            tadj_3D ...
            exp_travtime_3D ...
            exp_arvltime_3D ...
            tres_3D ...
            ... %
            twosd ...
            SNR ...
            max_counts ...
            max_delay ...
            ... %
            contrib_eventid ...
            iris_eventid ...
            ... %
            kstnm ...
            phase_name ...
            rviewr ...
           };

    fprintf(fid, fmt, data{:});

end
fclose(fid);
fprintf('Max. tdiff: %.48f s (%s)\n', max_tdiff, strippath(max_tdiff_sac))

% Use a system call to sort the new entries.
status = system(sprintf('sort -k1 -n -o %s %s', filename, filename));
if status ~= 0
    warning('unable to sort %s\nflags may differ on non-Linux machines', filename)

end
writeaccess('lock', filename);
fprintf('Wrote: %s\n', filename)

%% This is outdated.
% Here is a current list of column-end indices, starting from 0:
%
%  43
%  73
%  90
% 106
% 117
% 130
% 144
% 174
% 191
% 207
% 220
% 233
% 248
% 262
% 277
% 292
% 307
% 321
% 335
% 350
% 364
% 378
% 391
% 406
% 420
% 434
% 447
% 462
% 476
% 490
% 504
% 520
% 543
% 555
% 577
% 593
% 605
% 615

%% ___________________________________________________________________________ %%

% Return (really, only keep) the first PKP phase in cases were PKP exists in phase list.
function EQ = onlyPKP(EQ)

phases = {EQ.TaupTimes.phaseName};
PKP_phases = cellstrfind(phases, 'PKP');
if ~isempty(PKP_phases)
    EQ.TaupTimes = EQ.TaupTimes(PKP_phases(1));

end
