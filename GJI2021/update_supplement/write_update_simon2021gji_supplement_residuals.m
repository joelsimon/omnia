function write_update_simon2021gji_supplement_residuals
% WRITE_UPDATE_SIMON2021GJI_SUPPLEMENT_RESIDUALS
%
% !! Must first run writefirstarrival.m !!
%
% This is a near copy of $OMNIA/GJI21/write_simon2021gji_supplement_residuals.m
% but written to allow update by the current MERMAID data set (the other is
% "locked" in time to only run on the data used in that study).  See there
% for notes.
%
% NB; formatted text file is not flexible enough to handle, e.g., changing
% event ID strings, so some previously formatted lines now run longer than
% expected, breaking the original associated `read` function.
%
% A future improvement would be to rewrite this read/write workflow as CSV.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 30-Jan-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

llnl_exists = false;

%% Preliminaries
clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');
datadir = fullfile(evtdir, 'reviewed', 'identified', 'txt');

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

%%            Identify the list of SAC files whose first phase is p or P                 %%
%%______________________________________________________________________________________%%

% Read the relevant SAC files from mer.firstarr.all.txt.
mer_det_txt1 = fullfile(datadir, 'firstarrival.txt');

% Use winnowfirstarrival.m because we only want p or P waves AND we don't want
% any with true win/zerflags.
FA = winnowfirstarrival(mer_det_txt1, [], [], [], {'p' 'P'});

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
    LL = winnowllnl(llnl_txt, mer_det_txt1, [], [], [], {'p' 'P'});

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
       '\n'];


%%______________________________________________________________________________________%%


filename = fullfile(datadir, 'update_simon2021gji_supplement_residuals.txt');

hdrline1 =  '#COLUMN:                                   1                             2                3               4          5            6             7                             8                9              10           11           12             13            14             15             16             17            18            19             20            21            22           23             24            25            26           27             28            29            30            31            32               33          34                35              36';
hdrline2 = ['#DESCRIPTION:                       FILENAME                    ' ...
            'EVENT_TIME             EVLO            EVLA    MAG_VAL     MAG_TYPE          EVDP               SEISMOGRAM_TIME             STLO            STLA         STDP         OCDP       1D_GCARC 1D*_GCARC_adj      1D*_GCARC   3D_GCARC_adj       3D_GCARC  OBS_TRAVTIME  OBS_ARVLTIME    1D_TRAVTIME   1D_ARVLTIME       1D_TRES 1D*_TIME_adj   1D*_TRAVTIME  1D*_ARVLTIME      1D*_TRES  3D_TIME_adj    3D_TRAVTIME   3D_ARVLTIME       3D_TRES      2STD_ERR           SNR       MAX_COUNTS    MAX_TIME           NEIC_ID         IRIS_ID'];

writeaccess('unlock', filename, false);
fid = fopen(filename, 'w');
fprintf(fid, '%s\n', hdrline1);
fprintf(fid, '%s\n', hdrline2);

max_tdiff_check = 0; % for testing
for i = 1:length(s);
    i
    % Retrieve the SAC header.
    sac = s{i};
    [~, h] = readsac(fullsac(s{i}, procdir));
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

    % Retrieve event structure.
    EQ = getrevevt(sac, evtdir);
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


    %% 26-Jan-2023: we can't run some of these validations because, unlike
    %% the "locked" firstarrival textfile used in the paper, the current
    %% firstarrival textfile that lives in $MERMAID/events/ might have had different
    %% parameters in use and thus things like `max_delay` and `max_counts`
    %% may differ. These validations really were just to test to make sure
    %% the old and current runs all used the same parameters, which we don't
    %% care about now because we are re-running firstarrival.m for ever .sac.

    % % Run some validations with FA (times written to text file with 2 decimal places
    % % of precision)
    % if abs(FA.tres(i)-tres_1Dadj) >= 1e-2 || ...
    %         abs(FA.dat(i)-obs_arvltime) >= 1e-2 || ...
    %         abs(FA.tadj(i)-exp_arvltime_1Dadj_diff) >= 1e-2 || ...
    %         abs(FA.delay(i)-max_delay) >= 1e-2 || ...
    %         abs(FA.maxc_y(i)-max_counts) >= 1e-2 || ...
    %         abs(FA.SNR(i)-SNR) >= 1e-2
    %     %abs(FA.syn(i)-exp_arvltime_1Dadj) >= 1e-2 || ... (no 'syn', but if 'obs_arvltime' and 'tres' match, so must 'exp_arvltime'

    %     keyboard
    %     error(sprintf('%s numbers don''t match: %s', strippath(mer_det_txt1), sac))

    % end

    % The travel time and arrival time time-adjustments (tadj) are equal because the
    % time elapsed between the event and the start of the seismogram is the same
    % in both cases and cancels.
    exp_travtime_1Dadj_diff  = exp_arvltime_1Dadj_diff;

    % Round the SNR; when its down in single digits is so low who cares if
    % its rounded.
    SNR = round(SNR);

    % The max. counts are non-integer due to filtering; round them because it's
    % meaningless to have a fractional count.
    max_counts = round(max_counts);

    %% 30-Jan-2023 (after already sending first round of updates to Dalija)
    %% Use recomputed `twosd` from firstarrival above, not from firstarrival
    %% text file (that uncertainty estimate could have been generated using
    %% different parameters or window lengths etc.
    % Use the saved uncertainty estimation (computed using the same firstarrival.m
    % and loaded with `winnowfirstarrival` above) so that the text file matches
    % example seismograms in the paper.
    %twosd = twosd_vector(i);


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
    tdiff_check = (EQ(1).TaupTimes(1).truearsecs - EQ(1).TaupTimes(1).pt0) - exp_arvltime_1D
    if tdiff_check > 1e-7 % s
        error('pt0-timing issue')

    end
    if abs(tdiff_check) > abs(max_tdiff_check)
        max_tdiff_check = tdiff_check;

    end
    fprintf('%.48f\n', max_tdiff_check)

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
           };

    fprintf(fid, fmt, data{:});

end
fclose(fid);
writeaccess('lock', filename);
