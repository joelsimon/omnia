function F = nearbyrecordsection(id, lohi, alignon, ampfac, mer_evtdir, mer_sacdir, normlize, nearbydir)
% F = NEARBYRECORDSECTION(id, lohi, alignon, ampfac, mer_evtdir, mer_sacdir, normlize, nearbydir)
%
% NEEDS HEADER AND WORKING 'ATIME' OPTION
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 14-Sep-2019, Version 2017b on GLNXA64

defval('id', '10948555')
defval('lohi', [1 5]);
defval('alignon', 'etime')
defval('ampfac', 3)
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('normlize', true)
defval('nearbydir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))

if strcmpi(alignon, 'atime')
    error('alignon = ''atime'' not yet coded')

end

% Plot the baseline MERMAID record section.
[F, mer_EQ] = recordsection(id, lohi, alignon, ampfac, mer_evtdir, ...
                            mer_sacdir, normlize);

% The event date for this ID is the same for every mer_EQ and is
% always the first EQ in the list.
evtdate = datetime(irisstr2date(mer_EQ{1}(1).PreferredTime));

% Get the nearby SAC files and EQ structures.
[~, ~, nearby_sac, nearby_EQ] = getnearbysacevt(id, mer_evtdir, mer_sacdir, nearbydir);

% Remove nearby EQ structures with no phase arrivals (empty
% .TaupTimes, e.g., in the case of incomplete or merged data).
rm_idx = [];
for i = 1:length(nearby_EQ)
    if isempty(nearby_EQ{i}(1).TaupTimes)
        rm_idx = [rm_idx i];

    end
end
nearby_EQ(rm_idx) = [];
nearby_sac(rm_idx) = [];

if strcmpi(alignon, 'etime')
    % Expand the x-axis (to the left) by starting 100 s (ish) before the first arrival.
    mer_first = cellfun(@(xx) xx(1).TaupTimes(1).arrivaldatetime, mer_EQ);
    nearby_first = cellfun(@(xx) xx(1).TaupTimes(1).arrivaldatetime, nearby_EQ);
    all_first = [mer_first nearby_first];
    min_first = min(all_first);
    F.ax.XLim(1) = round(seconds(min_first - evtdate) -  100, -2);

    % Expand the y-axis by 5 degrees beyond the min and max distances.
    mer_dists = cellfun(@(xx) xx(1).TaupTimes(1).distance, mer_EQ);
    nearby_dists = cellfun(@(xx) xx(1).TaupTimes(1).distance, nearby_EQ);
    all_dists = [mer_dists nearby_dists];
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

% This the requested number of seconds between the first sample of the
% seismogram and the theoretical first arrival; i.e., how long we
% want the noise segment to be on the abbreviated (shortened) trace.
abbrev_offset = 100; 

phase_cell = {};
for i = 1:length(nearby_EQ)
    tt = nearby_EQ{i}(1).TaupTimes;
    if isempty(tt) 
        continue

    end

    % Parse the event info.
    dist(i) = tt.distance;

    % Read the NEARBY_SAC data.
    [x{i}, h{i}] = readsac(nearby_sac{i});

    fs = round(1 / h{i}.DELTA);
    if fs > 20
        R = floor(fs / 20);
        x{i} = decimate(x{i}, R);
        h{i}.DELTA = h{i}.DELTA * R;
        fprintf('\nDecimated %s from %i to %i [Hz]', nearby_EQ{i}(1).Filename, fs, round(1 / h{i}.DELTA))

    end

    % This is the current "time" (NOT ABSOLUTE IN UTC) in seconds assigned
    % the first sample; all times in tt are in reference to this time.
    full_pt0(i) = tt(1).pt0;

    % This is the currently defined x-xaxis for the complete trace.
    full_xax{i} = xaxis(h{i}.NPTS, h{i}.DELTA, full_pt0(i));

    % This is the current number of seconds between the first sample of
    % the seismogram and the theoretical first arrival; i.e. the
    % length of the noise segment.
    full_offset = tt(1).truearsecs - tt(1).pt0;
    
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
    % [abbrev_x{i}, abbrev_W(i)] = timewindow(x{i}, NaN, abbrev_pt0, ...
    %                                         'first', h{i}.DELTA, full_pt0);

    [abbrev_x{i}, abbrev_W(i)] = timewindow(x{i}, 250, abbrev_pt0(i), ...
                                             'first', h{i}.DELTA, full_pt0(i));
    abbrev_xax{i} = abbrev_W(i).xax;

    % Taper and filter.
    if ~isnan(lohi)
        taper = hanning(length(abbrev_x{i}));
        abbrev_x{i} = bandpass(taper .* abbrev_x{i}, 1/h{i}.DELTA, lohi(1), lohi(2));

    end

    % % This is the arrival time (s) still in the timing-reference of the
    % % full trace.
    % abbrev_first_arrival = abbrev_pt0 + abbrev_offset;

    % % We want to normalize to the maximum value of the first arrival. Take
    % % a time window that is 30 seconds, centered on first arrival time.
    % [abbrev_x_first{i}, abbrev_W_first(i)] = ...
    %     timewindow(abbrev_x{i}, 30, abbrev_first_arrival, 'middle', h{i}.DELTA, abbrev_pt0);
    % abbrev_xax_first{i} = abbrev_W_first(i).xax;

    % Identify the phases in the abbreviated segments only.
    arrival_times = [tt.truearsecs];
    xlims = minmax((abbrev_xax{1}'));
    arrival_idx = arrival_times >= xlims(1) & arrival_times <= xlims(2);
    phase_cell = [phase_cell {tt(arrival_idx).phaseName}];


end

% This is the max amplitude across all seismograms (i.e., likely the
% one with the shortest epicentral distance, ignoring propagation
% patterns etc.) and may be used below to normalize but maintain
% distance decay.
%maxx = max(cellfun(@(xx) max(abs(xx)), abbrev_x_first));

% Cannot do:
 maxx = max(cellfun(@(xx) max(abs(xx)), abbrev_x));
% in case one empty abbrev_x (if an EQ structure was skipped due to e tt = [])
% for i = 1:length(abbrev_x)
%     if isempty(abbrev_x{i}) 
%         abbrev_maxx(i) = 0;

%     else
%         abbrev_maxx(i) = max(abs(abbrev_x{i}));

%     end
% end
% maxx = max(abbrev_maxx);

nearby_color = repmat(0.5, [1, 3]);

hold(F.ax, 'on');
% Normalize the traces and annotate with float numbers.
for i = 1:length(abbrev_x)
    if normlize
        % Normalize this seismogram with itself, thereby removing distance
        % decay.
        %       abbrev_x{i} = abbrev_x{i} / max(abs(abbrev_x_first{i}));
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
    
    % seisdate is in absolute UTC time.
    seisdate{i} = seistime(h{i});

    % delay is in absolute UTC time between event rupture and the first
    % sample of the full trace.
    delay = seisdate{i}.B - evtdate;

    full_evt_pt0 = seconds(delay);
    diff_pt0 = abbrev_pt0(i) - full_pt0(i);

    abbrev_evt_pt0 = full_evt_pt0 + diff_pt0;
    evt_xax{i} = xaxis(length(abbrev_x{i}), h{i}.DELTA, abbrev_evt_pt0);

    F.pltr2(i) = plot(F.ax, evt_xax{i}, ampfac * abbrev_x{i} + dist(i));
    F.pltr2(i).Color = nearby_color;

    % Assumes Princeton MERMAID float naming convention, where the float
    % number is the two digits immediately following the first period
    % in the NEARBY_SAC filename.
    station_info = strsplit(strippath(nearby_sac{i}), '.');
    floatnum = cell2commasepstr(station_info(1:4), '.');

    F.pltx2(i) = text(F.ax, 0, dist(i), sprintf('%14s', num2str(floatnum)));
    F.pltx2(i).Color = nearby_color;

end

if strcmpi(alignon, 'atime')
    % XLabel specific to aligning on first-arrival.
    evttime = nearby_EQ{1}.PreferredTime;
    F.xl = xlabel(sprintf(['time relative to first arrival(s)\n[origin: ' ...
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

    % Compute travel time curves for the phases present.
    phase_cell = [F.lg.String phase_cell];
    phase_cell = unique(phase_cell);
    delete(F.ph);

    phase_str = cell2commasepstr(phase_cell, ', ');
    tc = taupCurve('ak135', nearby_EQ{1}(1).PreferredDepth, phase_str);

    % Overlay travel time curves.
    for i = 1:length(tc)
        if isempty(tc(i).time)
            rm_idx = [rm_idx i];
            continue

        end
        F.ph(i) = plot(F.ax, tc(i).time, tc(i).distance, 'LineWidth', ...
                       1.5, 'LineStyle', '-');
        
    end
    phase_cell(rm_idx) = [];
    F.ph(rm_idx) = [];
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
