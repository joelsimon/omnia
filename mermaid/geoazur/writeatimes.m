% WRITEATIMES
%
% Script to writes arrival times and SNRs for GeoAzur MERMAID data to
% $MERAZUR/textfiles/arrivaltimes.txt
%
% All data is culled from the SAC header, except for the (reported by
% GA) matching phase, which is looked for first in 'm??_events.txt'
% then 'events.txt'
% 
% AGAIN: the only data from *events.tx is the reported phase name.
% Everything else from the header.
%
% Differs from writeatimes2.m in that it considers all scales
% including approximation, and is massively simplified to only save
% the timing information for the complete segmentation (changepoint.m
% not run again on a windowed segmentation of the seismogram).  Also
% computes the arrival times time domain, not he time-scale domain.
%
% Columns of arrivaltimes.txt
% (1): SAC filename
% (2): Phase name as recorded in m??-events.txt  or events.txt 
% (3): The absolute travel time of the specified phase in seconds
% (4): GA's arrival time for the specified phase computed with ak135
% (5-10): JD's arrival times computed with complete seismogram
%             at all scales
% (11): Rounded sampling frequency of seismogram (Hz)
%
% Note that NaNs in arrival time columns signify that either:
%
% (1) No sensitivity at that frequency (scale 1 is for data sampled at
%     20 Hz; e.g., 5 Hz seismograms scale 1 is actually 20 Hz
%     seismograms scale 3).
%
% (2) the corresponding SNR at that scale is less than or equal to
%     1 thus not considered an arrival.
%
% See also: readatimes.m, changepoint.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Jan-2019, Version 2017b

close all
clear

% Inputs for changepoint.m
inputs.tipe =  'CDF';
inputs.nvm =  [2 4];
inputs.pph =  4;
inputs.intel =  0;
inputs.rmedge =  true;
inputs.meth =  1;
inputs.algo =  'fast';
inputs.dtrnd =  0;
inputs.bias =  true;
inputs.cptype =  'kw';
inputs.iters =  [];
inputs.alphas =  [];
inputs.dists =  [];
inputs.stdnorm = false;

% AIC and variance computations use a biased estimate of the variance.
bias = true;

% Grab all the 'identified' SAC files and paths.
s = mermaid_sacf('id');

% File to save arrival times.
afile = fullfile(getenv('MERAZUR'), 'textfiles', 'arrivaltimes.txt');

% Remove any arrivaltimes.txt file that might already exist.
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
fs20 = 0;

% Loop through every SAC file.
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

    % Add asterisks to phase name if multiple arrivals in seismogram time
    % window, and increment a multi-arrival counter.
    if length(tt) > 1
        ph = ['*' ph];
        multi_arr = multi_arr + 1;
        
    end

    % The number of wavelet scales to decompose the seismogram is based on
    % the sampling frequency. See discussion in header.
    fs = 1/h.DELTA;

    if round(fs) == 5
        fs5 = fs5 + 1;
        n = 3;
        padd = [NaN NaN];
        
    elseif round(fs) == 20
        fs20 = fs20 + 1;
        n = 5;
        padd = [];

    else
        error('Unexpected frequency for NaN padding.  Update writeatimes.m')

    end

    % GeoAzur time (ga) is the arrival time of specified phase.  If there
    % are multiple arrivals, take the first.
    ga_time = tt(1).arsecs;

    % Compute both multiscale arrival times
    CP = changepoint('time', x, n, h.DELTA, h.B, 1, inputs);

    % Might have to pad it with NaNs depending on sampling frequency
    % (means data doesn't exist at that frequency, NOT that arrival
    % time SNR < cutoff).
    jd_time = [padd cell2mat(CP.arsecs)];

    %**N.B The SNR will be inf if the length of finite values in noise
    % segment is 1.
    
    % Write a line of arrival time information.
    fmt = ['%23s '   ...                 % 1
           '%8s '    ...                 % 2
           '%7.2f '  ...                 % 3
           '%6.2f '  ...                 % 4
           repmat('%6.2f ',  [1 6])  ... % 5-10
           '%2u\n'];                     % 11
    
    data = {sacfile,    ...       % 1
            ph,         ...       % 2
            tt(1).time, ...       % 3
            ga_time,    ...       % 4
            jd_time,    ...       % 5-10
            round(fs)};           % 11

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
fprintf('Number of 5 Hz SAC files: %i\n', fs5)

