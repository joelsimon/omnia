function F = nearbyrecordsection(id, lohi, alignon, ampfac, mer_evtdir, ...
                                 mer_sacdir, normlize, nearbydir, returntype, ph, ...
                                 otype, includeCPPT)
% F = NEARBYRECORDSECTION(id, lohi, alignon, ampfac, mer_evtdir, mer_sacdir, ...
%         normlize, nearbydir, returntype, ph, otype, includeCPPT)
%
%% NEED TO ADD nearby_sacu; nearby_EQu -- no: merged traces is fine here.
%
% NEEDS HEADER AND WORKING 'ATIME' OPTION
% returntype   For third-generation+ MERMAID only:
%              'ALL': both triggered and user-requested SAC files
%              'DET': triggered SAC files as determined by onboard algorithm (def)
%              'REQ': user-requested SAC files
% otype        []: (empty) return raw time series
%              'none': return displacement time series (nm)
%              'vel': return velocity time series (nm/s)
%              'acc': return acceleration time series (nm/s/s) (def)
% includeCPPT  true to include CPPT traces (NB, if true, the path to CPPT data
%                  must mirror exactly 'nearbydir', except that "nearby" in the
%                  former is replaced with "cppt" in the latter) (def: true)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('id', '10948555')
defval('lohi', [1 5]);
defval('alignon', 'etime')
defval('ampfac', 3)
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('normlize', true)
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('returntype', 'DET')
defval('ph', [])
defval('otype', 'none')
defval('includeCPPT', true)

if strcmpi(alignon, 'atime')
    error('alignon = ''atime'' not yet coded')

end

% Plot the baseline MERMAID record section.
[F, mer_EQ] = recordsection(id, lohi, alignon, ampfac, mer_evtdir, ...
                            mer_sacdir, normlize, returntype, ph);
if isempty(mer_EQ)
    return

end

% The event date for this ID is the same for every mer_EQ and is
% always the first EQ in the list.
evtdate = datetime(irisstr2date(mer_EQ{1}(1).PreferredTime));

% Get the nearby SAC files and EQ structures.
[~, ~, nearby_sac, nearby_EQ] = ...
    getnearbysacevt(id, mer_evtdir, mer_sacdir, nearbydir, true, returntype, otype);

% Fetch the similar CPPT data, if requested.
if includeCPPT
    cpptdir = strrep(nearbydir, 'nearby', 'cppt');
    [~, ~, cppt_sac, cppt_EQ] = ...
        getcpptsacevt(id, mer_evtdir, mer_sacdir, cpptdir, true, returntype, otype);

    % Concatenate with the "nearby" stations' data.
    nearby_sac = [nearby_sac ; cppt_sac];
    nearby_EQ = [nearby_EQ ; cppt_EQ];

end

% Remove nearby EQ structures with no phase arrivals (empty
% .TaupTimes, e.g., in the case of incomplete or merged data).
rm_idx = [];
for i = 1:length(nearby_EQ)
    if isempty(nearby_EQ{i})
        rm_idx = [rm_idx i];

    end
end
nearby_EQ(rm_idx) = [];
nearby_sac(rm_idx) = [];
clearvars('rm_idx')

% This the requested number of seconds between the first sample of the
% seismogram and the theoretical first arrival; i.e., how long we
% want the noise segment to be on the abbreviated (shortened) trace.
abbrev_offset = 100;

% We want to compare apples-to-apples phase wise so ensure we are
% looking at the same phase / phase branch in nearby_EQ as the first
% arrivals in mer_EQ;
first_phase_idx = firstnearbyphase(mer_EQ, nearby_EQ);

% If there is no reportedly-matching phase in the nearby_EQ struct,
% remove that structure entirely, as well as the corresponding nearby_sac index.
rm_idx = find(isnan(first_phase_idx));
nearby_EQ(rm_idx) = [];
nearby_sac(rm_idx) = [];

% Finally remove the NaN indices from first_phase_idx itself s.t. the
% indexing now matches that of nearby_EQ and nearby_sac.
first_phase_idx(rm_idx) = [];
clearvars('rm_idx')

if strcmpi(alignon, 'etime')
    % Expand the x-axis (to the left) by starting 100 s (ish) before the first arrival.
    mer_first = cellfun(@(xx) xx(1).TaupTimes(1).arrivaldatetime, mer_EQ);
    nearby_first = cellfun(@(xx) xx(1).TaupTimes(1).arrivaldatetime, nearby_EQ);
    all_first = [mer_first ; nearby_first];
    min_first = min(all_first);
    F.ax.XLim(1) = round(seconds(min_first - evtdate) - 100, -2);

    % Expand the y-axis by 10 degrees beyond the min and max distances.
    mer_dists = cellfun(@(xx) xx(1).TaupTimes(1).distance, mer_EQ);
    nearby_dists = cellfun(@(xx) xx(1).TaupTimes(1).distance, nearby_EQ);
    all_dists = [mer_dists ; nearby_dists];
    min_dist = min(all_dists) - 10;
    max_dist = max(all_dists) + 10;
    if min_dist < 0
        min_dist = 0;

    end
    if max_dist > 180
        max_dist = 180;

    end
    F.ax.YLim = round([min_dist max_dist], -1);

end

phase_cell = {};
for i = 1:length(nearby_EQ)
    tt = nearby_EQ{i}.TaupTimes;

    % Note this event's distance -- just take the distance attached to the
    % first phase as they distance does not vary between phases.
    dist(i) = tt(1).distance;

    % Read the NEARBY_SAC data.
    [x{i}, h{i}] = readsac(nearby_sac{i});

    % seisdate is in absolute UTC time.
    seisdate{i} = seistime(h{i});

    % Decimate the data to get as close as possible to 20 Hz.
    if isnan(lohi)
        fs = round(1 / h{i}.DELTA);
        if fs > 20
            R = floor(fs / 20);
            x{i} = decimate(x{i}, R);

            %% Very important: adjust the appropriate header variables .NPTS and .DELTA
            h{i}.NPTS = length(x{i});
            h{i}.DELTA = h{i}.DELTA * R;

            fprintf('\nDecimated %s from %i to %i [Hz]\n', nearby_EQ{i}(1).Filename, fs, round(1 / h{i}.DELTA))

        end
    end

    % This is the current "time" (NOT ABSOLUTE IN UTC) in seconds assigned
    % the first sample; all times in tt are in reference to this time.
    full_pt0(i) = tt(first_phase_idx(i)).pt0;

    % This is the currently defined x-xaxis for the complete trace
    % (possibly after decimation).
    full_xax{i} = xaxis(h{i}.NPTS, h{i}.DELTA, full_pt0(i));

    % This is the current number of seconds between the first sample of
    % the seismogram and the theoretical first arrival; i.e. the
    % length of the noise segment.
    %
    % N.B: here we don't use tt(1) we use tt(first_phase_idx(1))
    % because we want to compare the phase in nearby_EQ that most
    % closesly matches the first arriving phase(s) in MERMAID data;
    % e.g., if tt(1).phaseName = 'Pdiff' and the first phase in
    % MERMAID is 'PKIKP' then we don't want to use tt(1).
    full_offset = tt(first_phase_idx(i)).truearsecs - tt(first_phase_idx(i)).pt0;

    % This is the time assigned first sample of the abbreviated segment,
    % still in the same reference of full_xax.
    abbrev_pt0(i) = full_offset - abbrev_offset;

    % Correct cases when the full offset (time between first sample and
    % first arrival) is less than the requested abbreviated offset
    % (i.e., in the case of incomplete data).
    if abbrev_pt0(i) < 0
        abbrev_pt0(i) = full_pt0(i);

    end

    % This returns the abbreviated trace and its window in reference to
    % the full trace.
    [abbrev_x{i}, abbrev_W(i)] = timewindow(x{i}, 250, abbrev_pt0(i), ...
                                             'first', h{i}.DELTA, full_pt0(i));
    abbrev_xax{i} = abbrev_W(i).xax;

    % Taper and filter.
    if ~isnan(lohi)
        taper = hanning(length(abbrev_x{i}));
        abbrev_x{i} = detrend(abbrev_x{i}, 'constant');
        abbrev_x{i} = detrend(abbrev_x{i}, 'linear');
        abbrev_x{i} = taper .* abbrev_x{i};
        abbrev_x{i} = bandpass(abbrev_x{i}, 1/h{i}.DELTA, lohi(1), lohi(2), 2, 2, 'butter');

    end

    % Identify the phases in the abbreviated segments only.
    arrival_times = [tt.truearsecs];
    xlims = minmax(abbrev_xax{i}');
    arrival_idx = arrival_times >= xlims(1) & arrival_times <= xlims(2);
    phase_cell = [phase_cell {tt(arrival_idx).phaseName}];

end

% This is the max amplitude across all seismograms (i.e., likely the
% one with the shortest epicentral distance, ignoring propagation
% patterns etc.) and may be used below to normalize but maintain
% distance decay.
maxx = max(cellfun(@(xx) max(abs(xx)), abbrev_x));

nearby_color = repmat(0.5, [1, 3]);
hold(F.ax, 'on');
% Normalize the traces and annotate with float numbers.
for i = 1:length(abbrev_x)
    if normlize
        % Normalize this seismogram with itself, thereby removing distance
        % decay.
        abbrev_x{i} = norm2max(abbrev_x{i});

    else
        % Normalize this seismogram with max amplitude of all
        % seismograms, thereby showing distance decay.
        abbrev_x{i} = abbrev_x{i} / maxx;

    end

    % Verify all the timing makes sense.
    % figure
    % hold on
    % plot(full_xax{i}, norm2max(x{i}), 'k')
    % plot(abbrev_xax{i}, norm2max(abbrev_x{i}), 'm')
    % plot(abbrev_xax_first{i}, norm2max(abbrev_x_first{i}), 'r')
    % hold off

    % Thus far all timing has been in reference to the full trace and its
    % arbitrarily-defined time at the first sample (h{i}.B in the
    % header == tt(i).pt0 == full.pt0).  This time is exactly
    % seisdate.B.  So all we need to do is find the delay (number of
    % seconds) between the evtdate and seisdate.B and subtract it from
    % the abbreviated trace to set the time of the first sample of the
    % abbreviated zero trace to 0.

    % delay is in absolute UTC time between event rupture and the first
    % sample of the full trace.
    delay = seisdate{i}.B - evtdate;

    full_evt_pt0 = seconds(delay);
    diff_pt0 = abbrev_pt0(i) - full_pt0(i);

    abbrev_evt_pt0 = full_evt_pt0 + diff_pt0;
    evt_xax{i} = xaxis(length(abbrev_x{i}), h{i}.DELTA, abbrev_evt_pt0);

    F.pltr2(i) = plot(F.ax, evt_xax{i}, ampfac * abbrev_x{i} + dist(i));
    F.pltr2(i).Color = nearby_color;


    % CPPT SAC file names start with  number; "nearby" start with a letter.
    sta_name = strippath(nearby_sac{i});

    % For "nearby stations:"
    % This unique network.station.location.channel name may be found by
    % keeping all characters up to the fourth period ('.')
    % delimiter. DO NOT USE strsplit because it ignores
    % empties between delims (e.g.,
    % AU.NIUE..BHZ.2018.220.01.38.57.SAC.acc, where the
    % location is missing).
    % station_info = strsplit(strippath(nearby_sac{i}), '.');
    % floatnum = cell2commasepstr(station_info(1:4), '.');
    delims = strfind(sta_name, '.');

    if isempty(str2num(sta_name(1)))
        % "nearby"
        sta = sta_name(1:delims(4)-1);

    else
        % CPPT (RSP network)
        ntwk = 'RSP';
        sta = [ntwk '.' sta_name(delims(4)+1:delims(5)-1)];

    end
    F.pltx2(i) = text(F.ax, 0, dist(i), sprintf('%14s', sta));
    F.pltx2(i).Color = nearby_color;

end

if strcmpi(alignon, 'atime')
    % XLabel specific to aligning on first-arrival.
    evttime = nearby_EQ{1}.PreferredTime;
    F.xl = xlabel(sprintf(['Time relative to first arrival(s)\n[origin: ' ...
                        '%s UTC]'], evttime));

    warning(['Theoretical first arrival may not be the same phase ' ...
             'or phase branch across different seismograms'])

    % Add vertical line at 0 seconds.
    F.vl = plot(F.ax, [0 0], get(F.ax, 'XLim'), 'k');
    botz(F.vl);

else
    % Update the rhs XLim using the last time of the furthest trace.
    [~, furthest] = max(dist);
    last_time = evt_xax{furthest}(end);
    F.ax.XLim(2) = round(last_time +  100, -2);

    % Travel-time curves
    if isempty(ph)
        % All phases potentially present.
        phase_cell = [F.lg.String phase_cell];
        phase_cell = unique(phase_cell);
        phase_str = cell2commasepstr(phase_cell, ', ');

    else
        % Just those requested.
        phase_str = ph;
        phase_cell = commasepstr2cell(ph, ',')

    end
    delete(F.ph);
    tc = taupCurve('ak135', nearby_EQ{1}(1).PreferredDepth, phase_str);

    % Overlay travel time curves.
    rm_idx = [];
    for i = 1:length(tc)
        if isempty(tc(i).time)
            rm_idx = [rm_idx i];
            continue

        end
        F.ph(i) = plot(F.ax, tc(i).time, tc(i).distance, 'LineWidth', ...
                       1.5, 'LineStyle', '-');

    end
    if ~isempty(rm_idx)
        phase_cell(rm_idx) = [];
        F.ph(rm_idx) = [];

    end
    F.lg = legend(F.ph, phase_cell, 'AutoUpdate', 'off', 'Location', ...
                  'NorthWest', 'FontSize', F.xl.FontSize);


    % Send travel time curves to the bottom.
    botz(F.ph, F.ax);

end
hold(F.ax, 'off')

% Shift and stagger the float numbers -- have to redo for MERMAID because of the x-axis update.
rangex = range(F.ax.XLim);
shiftx = rangex * 0.025;
for i = 1:length(F.pltx)
    if mod(i, 2) ~= 0
        F.pltx(i).Position(1) = F.pltx(i).Position(1) - (0.875 * shiftx); % 1.75 to account for width of number.

    else
        F.pltx(i).Position(1) = F.pltx(i).Position(1) + (0.5 * shiftx);

    end
end

for i = 1:length(F.pltx2)
    F.pltx2(i).Position(1) = F.ax.XLim(2) + shiftx;

end

botz(F.pltr2)
latimes
axesfs(F.f, 13, 13)
set(F.pltx2, 'FontSize', 9)
movev(F.tl, 1)
