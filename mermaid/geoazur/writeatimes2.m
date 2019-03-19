% WRITEATIMES2
%
% Script to writes arrival times and SNRs for GeoAzur MERMAID data to
% $MERAZUR/textfiles/arrivaltimes2.txt
%
% See: $MERAZUR/textfiles/README_arrivaltimes.txt
%
% GeoAzur (GA) time computed with arrivaltime.m* assuming event
% information taken from each seismogram's header (which seem more
% up-to-date than the associated line in $MEREVENTS/events.txt) and
% Earth model ak135.  Note that arrivaltime.m returns a tt structure
% with fields "truearsecs" and "arsecs".  The former is the exact
% difference between the start of the seismogram (sample 1 at t = 0
% s), while the latter is the time of the sample nearest the exact
% time (there is unlikely to be a sample EXACTLY at the time of the
% arrival).  The latter, rounded time is used as the GA (GeoAzur)
% arrival time.
%
% Joel D. Simon (JD) time computed with changepoint.m, run twice, once
% on the complete time series and a second time on a 100 s window
% roughly centered on the middle of the seismogram. Changepoint is set
% to 'time-scale' domain with default parameters.  The arrival time
% chosen as the JD time is the middle index of the arsecs time smear.
% 
% Columns of arrivaltimes2.txt
% (1): SAC filename
% (2): Phase name as recorded in $MEREVENTS/events.txt or m??-events.txt 
% (3): The absolute travel time of the specified phase in seconds
% (4): GA's arrival time for the specified phase computed with ak135
% (5-9): GA's wavelet domain SNRs relative to complete seismogram 
%            (at 8 4 2 1 0.5 Hz)
% (10-14): GA's wavelet domain SNRs relative to windowed portion 
%            (at 8 4 2 1 0.5 Hz)
% (15-19): JD's arrival times computed with complete seismogram
%            (at 8 4 2 1 0.5 Hz)
% (20-24): JD's wavelet domain SNRs relative to complete seismogram 
%            (at 8 4 2 1 0.5 Hz)
% (25-29): JD's arrival times computed with windowed portion
%            (at 8 4 2 1 0.5 Hz)
% (30-34): JD's wavelet domain SNRs relative to windowed portion 
%            (at 8 4 2 1 0.5 Hz)
% (35): Time (s) at first sample of windowed portion
% (36): Time (s) of window
% (37): Rounded sampling frequency of seismogram (Hz)
%
% Note that NaNs in arrival time columns signify that either:
%
% (1) the SAC file had a 5 Hz sampling frequency and thus no
%     sensitivity to 8 or 4 Hz (the first two arrival time columns).
%
% e.g [~, cfreq20] = scale2freq(20, 4)
%     [~, cfreq5]  = scale2freq(5, 2)  
%     cfreq20(3:4) == cfreq5(1:2)
%
% -- OR -- 
%
% (2) the corresponding SNR at that scale is less than or equal to
%     1 thus not considered an arrival.
%
% See also: readatimes.m, changepoint.m
%
% Documented pp. 69, 97, 115* 2017.1
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-Dec-2018, Version 2017b

close all
clear

wlen = 100;
bias = true;

% Grab all the 'identified' SAC files and paths.
s = mermaid_sacf('id');

% File to save arrival times.
afile = fullfile(getenv('MERAZUR'), 'textfiles', 'arrivaltimes2.txt');

% Remove any arrivaltimes2.txt file that might already exist.
if exist(afile, 'file')
    system(sprintf('rm -f %s', afile));

end

% Open a new clean file.
fid = fopen(afile, 'w');

% This is a tally of the number of seismograms whose phase in
% "events.txt" does not arrive in the seismogram's time window.
no_phase = 0;

% This is a tally of the number of seismograms without an event line
% (no phase name) in "events.txt".
no_evtline = 0;

% This is for a tally of the number of seismograms who have multiple
% arrivals of the same phase in the time window. I currently just take
% the first-arriving phase to be the "arrival."  Curious how dangerous
% of an assumption that is.
multi_arr = 0;

% Tally of number of SAC files with various sampling frequencies.
fs5 = 0;
fs10 = 0;
fs20 = 0;

% Loop through ever SAC file.
for i = 1:length(s)

    % Read specific SAC file data and header
    sacfile = s{i};
    [x, h] = readsac(sacfile);

    % Fetch seismogram, reference time, and event time from header.
    [seisdate, ~, ~, refdate, evtdate] = seistime(h);

    % Compute the arrival time given the phase specified in GeoAzur's events.txt
    sacfile = strippath(sacfile);
    
    % To find the (presumed by GeoAzur) phase first check the event file
    % in the individual float's sub directory.
    floatnum = sacfile(2:3);
    evtfile = fullfile(getenv('MERAZUR'), 'events', ...
                       sprintf('mermaid%s/m%s_events.txt', floatnum, floatnum));

    % mgrep.m the phase.  
    [~, evtline] = mgrep(evtfile, sacfile);

    if isempty(evtline)        

        % Event line wasn't found in "m??-events.txt" so look for it in
        % "events.txt" in the top-level directory.  For some reason,
        %
        % 'm16.20150323T102337.sac'
        % 'm16.20150512T071310.sac'
        % 'm16.20150902T012650.sac'    
        %
        % are not included in the "m16_events.txt" but are in "events.txt".

        % Fetch 16-Jul-2018: I verified that if event line in both text files
        % they are identical so it doesn't matter which order I search
        % ("m??_events.txt" or "events.txt" first).

        evtfile = fullfile(getenv('MEREVENTS'), 'events.txt');
        [~, evtline] = mgrep(evtfile, sacfile);

        if isempty(evtline)
            % No event line in either "m??_events.txt" or events.txt
            no_evtline = no_evtline + 1;
            continue
            
        end
    end

    % Parse phase from matching line in 'events.txt'.
    ph = strtrim(evtline{1}(103:110));

    % TauP travel time for that phase via my arrivaltimes.m wrapper.
    tt = arrivaltime(h, evtdate, [h.EVLA h.EVLO], 'ak135', h.EVDP, purist(ph));

    if isempty(tt)

        % 'Phases don't exist at specified distance!'  Try lowercase phase
        % name because it may be an upgoing P wave ('p'), 
        % e.g., 'm31.20161028T200310.sac'.
        tt = arrivaltime(h, evtdate, [h.EVLA h.EVLO], 'ak135', ...
                         h.EVDP, lower(purist(ph)));

        if isempty(tt)

            % If that still fails, try with a different velocity model, e.g.,
            % 'm33.20150530T113345.sac'.  In this case the GA phase is
            % 'Pdiff'.  For reference, in ak135, the first arriving
            % 'P' phase arrives 0.25 seconds after the 'Pdiff' phase
            % as computed below using iasp91.
            tt = arrivaltime(h, evtdate, [h.EVLA h.EVLO], 'iasp91', ...
                             h.EVDP, purist(ph));
            
            if ~isempty(tt)
                warning('Used iasp91 velocity model for %s.', sacfile)

            else
                % That phase really doesn't exist at that distance/depth.
                no_phase = no_phase + 1;
                continue

            end
        end
    end

    if length(tt) > 1
        % Tally number of multi-arrival seismograms per phase.
        multi_arr = multi_arr + 1;

    end

    % The number of wavelet scales to decompose the seismogram is based on
    % the sampling frequency. See discussion in header.
    fs = 1/h.DELTA;

    if round(fs) == 5
        fs5 = fs5 + 1;
        n = 3;
        padd = [NaN NaN];
        
    elseif round(fs) == 10
        fs10 = fs10 + 1;
        n = 4;
        padd = [NaN];

    elseif round(fs) == 20
        fs20 = fs20 + 1;
        n = 5;
        padd = [];

    else
        warning('Unexpected frequency for NaN padding.')
        keyboard

    end
        
    % Find the pivot time.
    lx = length(x);
    xax = xaxis(lx, h.DELTA, 0);

    if h.USER2 ~= -12345
        % 'pivot' is the STA/LTA trigger time (USER2 is trigger sample).
        % Subtract 1 sample from USER2 to set the zero time at the
        % first sample.
        pivot = xax(h.USER2);
        
    else
        % 'pivot' is time at the middle of the seismogram.
        pivot = xax(round(lx/2));
        
    end

    % Compute both complete and windowed arrival times with an window
    % length of 100 seconds and an snrcut of 1.  CP(1) corresponds to
    % the complete seismogram and CP(2) corresponds to the windowed
    % segment.  Note to self: the purpose of windowing to is boost the
    % SNR.  Maybe there is in fact an arrival at 100 s but because
    % there it is transient it gets washed out with the noise that
    % follows leading to an SNR of the entire segment of < 1.
    CP(1) = changepoint('time-scale', x, n, h.DELTA, h.B, 1, [], [], 'middle');
    [xw, W] = timewindow(x, 100, pivot, 'middle', h.DELTA, h.B);
    CP(2) = changepoint('time-scale', xw, n, h.DELTA, W.xlsecs, 1, ...
                        [], [], 'middle');

    % GeoAzur time (ga) is the arrival time of specified phase.  If there
    % are multiple arrivals, take the first.
    ga_time = tt(1).arsecs;
    ga_samp(1) = tt(1).arsamp;

    % Project of ga_time into the wavelet (time-scale) domain to compute
    % SNRj assuming the arrival sample is the true start of the
    % "signal."  

    % ga_kw are the last details contained wholly in the "noise" section;
    % i.e., they are the last detail indices which do not see ga_samp
    % (the arrival).
    %
    % I want the cone of influence of a single ga time domain sample
    % so that I can convert that into the wavelet domain to get ga
    % SNRs (assumes the arrival is at the same time at every scale).
    % Because I've smoothed the changepoint.m output I need to
    % re-compute the complete abe and dbe time smears.
    inputs = CP(1).inputs;
    lx(1) = length(CP(1).outputs.xax);
    [abe, dbe] = wtspy(lx(1), inputs.tipe, inputs.nvm, inputs.n, ...
                       inputs.pph, inputs.intel);
   
    % These are the complete (not smoothed, as CP(?).outputs.dabe are)
    % time smears.
    dabe = [dbe abe];
    [~, ~, ga_kw{1}] = wtcoi(dabe(1:end-1), ga_samp(1), lx(1));
    ga_snr{1} = wtsnr(CP(1).outputs.da(1:end-1), ga_kw{1}, bias);    

    % Adjust the end of the noise sample such that it has the same zero
    % time as the start of the windowed segment.  (e.g., if ga_samp(1)
    % = 2 and W.xlSamp(1) = 1, we want ga_samp(2) = 2, not 3).
    ga_samp(2) = ga_samp(1) - (W.xlsamp - 1);
    lx(2) = length(CP(2).outputs.xax);
    
    % Overwriting abe, dbe for the windowed segmentation.
    [abe, dbe] = wtspy(lx(2), inputs.tipe, inputs.nvm, inputs.n, ...
                             inputs.pph, inputs.intel);
     dabe = [dbe abe];

    % If ga_time is within the windowed segment compute another, windowed,
    % SNRj.
    if W.xlsecs <= ga_time && ga_time <= W.xrsecs ...
            && ga_samp(2) ~= 1
        
        [~, ~, ga_kw{2}] = wtcoi(dabe(1:end-1), ga_samp(2), lx(2));
        ga_snr{2} = wtsnr(CP(2).outputs.da(1:end-1), ga_kw{2}, bias);

    else
        ga_snr{2} = NaN(n, 1);

    end

    % Might have to pad it with NaNs depending on sampling frequency
    % (means data doesn't exist at that frequency, NOT that arrival
    % time SNR < cutoff).
    for j = 1:2
        % Note here that I'm using the second index of the arrival as the
        % truth.
        jd_time{j} = [padd cell2mat(CP(j).arsecs(1:end-1))];
        jd_snr{j} = [padd CP(j).SNRj(1:end-1)];
        ga_snr{j} = [padd ga_snr{j}'];

    end

    %**N.B The SNR will be inf if the length of finite values in noise
    % segment is 1.
    
    % Write a line of arrival time information.
    fmt = ['%23s '   ...                 % 1
           '%7s '    ...                 % 2
           '%7.2f '  ...                 % 3
           '%6.2f '  ...                 % 4
           repmat('%11.5e ', [1 10]) ... % 5-14
           repmat('%6.2f ',  [1 5])  ... % 15-19
           repmat('%11.5e ', [1 5])  ... % 20-24
           repmat('%6.2f ',  [1 5])  ... % 25-29
           repmat('%11.5e ', [1 5])  ... % 30-34
           repmat('%6.2f ',  [1 2])  ... % 35-36
           '%2u\n'];                     % 37
    
    data = {sacfile,    ...       % 1
            ph,         ...       % 2
            tt(1).time, ...       % 3
            ga_time,    ...       % 4
            ga_snr{1},  ...       % 5-9
            ga_snr{2},  ...       % 10-14
            jd_time{1}, ...       % 15-19
            jd_snr{1},  ...       % 20-24
            jd_time{2}, ...       % 25-29
            jd_snr{2},  ...       % 30-34
            W.xlsecs,   ...       % 35
            W.wlensecs, ...       % 36
            round(fs)};           % 37

    fprintf(fid, fmt, data{:});

end

% Close file and add write protection.
fclose(fid);
system(sprintf('chmod 444 %s', afile));

fprintf('Total seismograms: %i\n', length(s))
fprintf('Number skipped due to no phase: %i\n', no_phase)
fprintf('Number skipped due to no event line: %i\n', no_evtline)
fprintf('Total number skipped: %i\n', no_evtline + no_phase)
fprintf('Number with multiple arrival: %i\n', multi_arr)
fprintf('Number of 20 Hz SAC files: %i\n', fs20)
fprintf('Number of 10 Hz SAC files: %i\n', fs10)
fprintf('Number of 5 Hz SAC files: %i\n', fs5)

% I think after all this work we won't end up using the plot that
% results (gatres2_*); regardless after thinking about more about this
% I want to make a warning that perhaps I'm not converting ga_time
% correctly into the wavelet domain (with wtcoi.m) -- I think I am
% doing it correctly by NOT removing a sample from the TauP arrival
% time before finding 'precede' in wtcoi.mm, but if I ever end up
% using this I want to make sure I think about this more.
warning('See note at bottom of this script')

