function [F, EQ, sac] = recordsection(id, lohi, alignon, ampfac, ...
                                      evtdir, procdir, normlize, returntype, ph)
% [F, EQ, sac] = ...
%     RECORDSECTION(id, lohi, alignon, ampfac, evtdir, procdir, normlize, returntype, ph)
%
% Plots a record section of all MERMAID seismograms that recorded the
% same event, according to 'identified.txt' (output of evt2txt.m)
%
% Input:
% id        Event identification number (def: 10948555)
% lohi      Bandpass (2 pole, 2 pass Butterworth) corner frequenies [Hz],
%               or NaN to plot raw seismograms  (def: [1 5])
% aligon    'etime': t=0 at event rupture time (def: etime)
%           'atime': t=0 at theoretical first arrival
%                    for every seismogram*
% ampfac    Nondimensional amplitude multiplication factor (def: 3)
% evtdir    Path to 'events' directory
%                (def: $MERMAID/events/)
% procdir   Path to 'processed' directory
%                (def: $MERMAID/processed/)
% normlize  true: normalize each seismogram against itself (def: true)
%                 (removes 1/dist amplitude decay)
%           false: normalize each seismogram against ensemble
%                 (preserves 1/dist amplitude decay)
% returntype   For third-generation+ MERMAID only:
%              'ALL': both triggered and user-requested SAC files
%              'DET': triggered SAC files as determined by onboard algorithm (def)
%              'REQ': user-requested SAC files
% ph        Comma separated list of phases whose travel time curves are to be overlain
%               (def: the phases present in the corresponding .evt files)
%
% Output:
% F        Structure with figure handles and bits
% EQ       EQ structure returned by cpsac2evt.m
% sac      SAC files whose traces are plotted
%
% *Theoretical travel time curves are not plotted if alignon =
% 'atime'.  Also note that a vertical line at 0 seconds does not
% necessarily correspond to the same phase / phase branch across
% different seismograms.  I.e., the 0 time for each seismogram is
% individually set to its first arrival, even if that first-arriving
% phase is different from the first-arriving phase of other
% seismograms plotted.  In the vast majority of cases the
% first-arriving phase be the same across all seismograms, but this is
% something to be aware of. Overlaid travel time curves for 'atime'
% option are on the wish list.
%
% Ex:
% RECORDSECTION(10948555, [], 'etime');
% RECORDSECTION(10948555, [], 'atime');
% RECORDSECTION(10937540, [1/10 1/2], 'etime', 3, [], [], true);
% RECORDSECTION(10937540, [1/10 1/2], 'etime', 3, [], [], false);
%
% See also: evt2txt.m, getevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Feb-2020, Version 2017b on GLNXA64

% Wish list:
%
% Input phase name option, to compute only requested travel time curves.
%
% Overlaid travel time curves for 'atime' option.  Compute differences
% between all phases and first-arriving phase at every distance.  Then
% set first-arriving phase at every distance to 0 seconds and all
% subsequent phase arrival times as those differences just computed.
% Will not be trivial because tt(?).distances may not intersect and
% thus would require interpolation between distances and times for
% different phases.  Alternatively, could compute travel times
% discretely for one phase given the tt(?).distance vector of another
% phase of interest, such that you are directly computing phase travel
% times at the same distances. This would be inefficient.

% Defaults.
defval('id', '10948555')
defval('lohi', [1 5]);
defval('alignon', 'etime')
defval('ampfac', 3)
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
defval('normlize', true)
defval('returntype', 'DET')
defval('ph', []);

% Find all the SAC files that match this event ID.
id = num2str(id);
sac = getsac(id, evtdir, procdir, returntype);
if isempty(sac)
    F = [];
    EQ = [];
    return

end

% Generate figure window.
F.f = figure;
fig2print(F.f, 'flandscape')
F.ax = axes(F.f);

phase_cell = {};
for i = 1:length(sac)
    % Retrieve the event data associated with that SAC file, as
    % found through sac2evt.m
    EQ{i} = getevt(sac{i}, evtdir);

    % Parse the event info.
    dist(i) = EQ{i}(1).TaupTimes(1).distance;
    phase_cell = [phase_cell {EQ{i}(1).TaupTimes.phaseName}];

    % Read the SAC data.
    [x{i}, h{i}] = readsac(sac{i});
    seisdate{i} = seistime(h{i});

    % First arrival, in seconds offset from first sample of the seismogram.
    offset = EQ{i}(1).TaupTimes(1).truearsecs - EQ{i}(1).TaupTimes(1).pt0;

    switch lower(alignon)
      case 'etime'
        % t = 0 at event rupture time (add travel time to time
        % series and subtract offset from arrival to start of seismogram)
        pt0 = EQ{i}(1).TaupTimes(1).time  - offset;

      case 'atime'
        % t = 0 at first phase arrival (subtract it from time series).
        pt0 = -offset;

      otherwise
        error('Please specify either ''etime'' or ''atime'' for input ''alignon''.')

    end
    % Generate an x-axis.
    xax{i} = xaxis(length(x{i}), h{i}.DELTA, pt0);

    % Taper and filter.
    if ~isnan(lohi)
        x{i} = detrend(x{i}, 'constant');        
        x{i} = detrend(x{i}, 'linear');
        taper = hanning(length(x{i}));
        x{i} = bandpass(taper .* x{i}, 1/h{i}.DELTA, lohi(1), lohi(2), 2, 2, 'butter');

    end

end
EQ = EQ(:);

% This is the max amplitude across all seismograms (i.e., likely the
% one with the shortest epicentral distance, ignoring propagation
% patterns etc.) and may be used below to normalize but maintain
% distance decay.
maxx = max(cellfun(@(xx) max(abs(xx)), x));

hold(F.ax, 'on');
% Normalize the traces and annotate with float numbers.
for i = 1:length(x)
    if normlize
        % Normalize this seismogram with itself, thereby removing distance
        % decay.
        x{i} = norm2max(x{i});

    else
        % Normalize this seismogram with max amplitude of all
        % seismograms, thereby showing distance decay.
        x{i} = x{i} / maxx;

    end

    % Assumes Princeton MERMAID float naming convention, where the float
    % number is the two digits immediately following the first period
    % in the SAC filename.
    floatnum = fx(strsplit(strippath(sac{i}), '.'), 2);
    floatnum = floatnum(1:2);

    F.pltr(i) = plot(F.ax, xax{i}, ampfac * x{i} + dist(i));
    F.pltx(i) = text(F.ax, 0, dist(i), num2str(floatnum));
    F.pltx(i).Color = F.pltr(i).Color;

end
F.ax.Box = 'on';
F.ax.TickDir = 'out';
grid(F.ax, 'on')

% Parse event info.  Event time is the same for all because it is the
% same event.
EQ1 = EQ{1}(1);
evttime = EQ1.PreferredTime;
magtype = [upper(EQ1.PreferredMagnitudeType(1)) ...
           lower(EQ1.PreferredMagnitudeType(2:end))];
magstr = sprintf('M%2.1f %s', EQ1.PreferredMagnitudeValue, magtype);
depthstr = sprintf('%2.1f km depth', EQ1.PreferredDepth);
locstr = sprintf('%s', EQ1.FlinnEngdahlRegionName);
F.tl = title([magstr ' ' locstr ' at ' depthstr]);

% Add labels.
current_xlim = get(F.ax, 'XLim');
current_ylim = get(F.ax, 'YLim');
if strcmpi(alignon, 'atime')
    % XLabel specific to aligning on first-arrival.
    F.xl = xlabel(sprintf(['Time relative to first arrival(s)\n[origin: ' ...
                        '%s UTC]'], evttime));

    warning(['Theoretical first arrival may not be the same phase ' ...
             'or phase branch across different seismograms'])

    % Add vertical line at 0 seconds.
    F.vl = plot(F.ax, [0 0], get(F.ax, 'XLim'), 'k');
    botz(F.vl);

else
    % Compute travel time curves.
    if ~isempty(ph)
        % Overwrite the phase_cell just built with those requested phases.
        phase_cell = commasepstr2cell(ph);

    end
    phase_cell = unique(phase_cell);
    phase_str = cell2commasepstr(phase_cell, ', ');
    tt = taupCurve('ak135', EQ1.PreferredDepth, phase_str);

    % Overlay travel time curves.
    phases_plotted = {};
    for i = 1:length(tt)
        F.ph(i) = plot(F.ax, tt(i).time, tt(i).distance, 'LineWidth', ...
                       1, 'LineStyle', '-');
        phases_plotted = [phases_plotted tt(i).phaseName];

    end

    % XLabel specific to aligning on event-rupture time.
    F.xl = xlabel(sprintf('Time relative to %s UTC (s)', evttime));
    %F.xl = xlabel(sprintf('time relative to %s UTC (s)\n[%s]', evttime, id));
    F.lg = legend(F.ph, phases_plotted, 'AutoUpdate', 'off', 'Location', ...
                  'NorthWest', 'FontSize', F.xl.FontSize);


    % Send travel time curves to the bottom.
    botz(F.ph, F.ax);

end
hold(F.ax, 'off')
set(F.ax, 'XLim', current_xlim);
set(F.ax, 'YLim', current_ylim);

% Annotate figure with bandpass corner frequencies.
if ~isnan(lohi)
    [F.lghz, F.txhz] = textpatch(F.ax, 'SouthEast', sprintf(['%.2f~-~%.2f ' ...
                        'Hz'], lohi), F.xl.FontSize, 'Times', true);

end

% Cosmetics.
F.yl = ylabel(F.ax, 'Epicentral distance (degrees)');
F.tl.FontWeight = 'normal';
latimes

% Shift and stagger the float numbers.
rangex = range(F.ax.XLim);
shiftx = rangex * 0.025;
for i = 1:length(F.pltx)
    if mod(i, 2) ~= 0
        F.pltx(i).Position(1) = xax{i}(1) - (1.6 * shiftx); % to account for width of number.

    else
        F.pltx(i).Position(1) = xax{i}(end) + shiftx;

    end
end
