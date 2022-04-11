function [F, EQ, sac] = recordsectioneq(sac, EQ, lohi, alignon, ampfac, normlize, ...
                                       ph, popas, taper)
% [F, EQ, sac] = RECORDSECTIONEQ(sac, EQ, lohi, alignon, ampfac, normlize, ...
%                               ph, popas, taper)
%
% Plot record section given lists of SAC and their assocaited identified EQ structs
%
% Input:
% sac       Cell array of SAC filenames
% EQ        Assocaited array of EQ structures
% lohi      Bandpass corner frequencies [Hz] (Butterworth filter),
%               or NaN to plot raw seismograms  (def: [1 5])
% aligon    'etime': t=0 at event rupture time (def: etime)
%           'atime': t=0 at theoretical first arrival
%                    for every seismogram*
% ampfac    Nondimensional amplitude multiplication factor (def: 3)
% normlize  true: normalize each seismogram against itself (def: true)
%                 (removes 1/dist amplitude decay)
%           false: normalize each seismogram against ensemble
%                 (preserves 1/dist amplitude decay)
% ph        Comma separated list of phases to overlay travel time curves
%               (def: the phases present in the corresponding .evt files)
% popas     1 x 2 array of number of poles and number of passes for bandpass
%               (def: [4 1])
% taper     0: do not taper before bandpass filtering (if any)
%           1: (def) taper with 0.1-ratio Tukey (`tukeywin`) before filtering
%           2: taper with Hann (`hanning`) before filtering
%
% Output:
% F        Structure with figure handles and bits
% EQ       EQ structure returned by cpsac2evt.m
% sac      SAC files whose traces are plotted
%
% *Theoretical travel time curves are not plotted if alignon = 'atime'.  Also
% note that a vertical line at 0 seconds does not necessarily correspond to the
% same phase / phase branch across different seismograms.  I.e., the 0 time for
% each seismogram is individually set to its first arrival, even if that
% first-arriving phase is different from the first-arriving phase of other
% seismograms plotted.  In the vast majority of cases the first-arriving phase
% be the same across all seismograms, but this is something to be aware
% of. Overlaid travel time curves for 'atime' option are on the wish list.
%
% See also: recordsection.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 28-Feb-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Wish list:
%
% *Specify decimation frequency, as in `firstarrival`
%
% *Overlaid travel time curves for 'atime' option.  Compute differences between
%  all phases and first-arriving phase at every distance.  Then set
%  first-arriving phase at every distance to 0 seconds and all subsequent phase
%  arrival times as those differences just computed.  Will not be trivial
%  because tt(?).distances may not intersect and thus would require
%  interpolation between distances and times for different phases.
%  Alternatively, could compute travel times discretely for one phase given the
%  tt(?).distance vector of another phase of interest, such that you are
%  directly computing phase travel times at the same distances. This would be
%  inefficient.

% Defaults.
defval('lohi', [1 5]);
defval('alignon', 'etime')
defval('ampfac', 3)
defval('normlize', true)
defval('ph', []);
defval('popas', [4 1]);
defval('taper', 1)

% Generate figure window.
F.f = figure;
fig2print(F.f, 'flandscape')
F.ax = axes(F.f);

phase_cell = {};
for i = 1:length(sac)
    % Retrieve the event data associated with that SAC file, as
    % found through sac2evt.m
    if ~strcmp(EQ{i}.Filename, strippath(sac{i}))
        error('EQ and SAC lists differ')

    end

    % Parse the event info.
    dist(i) = EQ{i}(1).TaupTimes(1).distance;
    phase_cell = [phase_cell {EQ{i}(1).TaupTimes.phaseName}];

    % Read the SAC data.
    [x{i}, h{i}] = readsac(sac{i});
    seisdate{i} = seistime(h{i});

    % First arrival, in seconds offset from the first sample of the seismogram (also
    % called the "arrival time" in paper?? because this removes any time shift
    % from .pt0; i.e. this is measured in seconds from the start of the
    % seismogram when the first sample is timestamped with 0 s).
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

    % Remove mean and trend from data.
    x{i} = detrend(x{i}, 'constant');
    x{i} = detrend(x{i}, 'linear');

    % Taper, maybe.
    switch taper
      case 1
        fprintf('Data tapered using `tukeywin`\n')
        x{i} = tukeywin(length(x{i}), 0.1) .* x{i};

      case 2
        fprintf('Data tapered using `hanning`\n')
        x{i} = hanning(length(x{i})) .* x{i};


      otherwise
        fprintf('Data not tapered\n')

    end

    % Filter, maybe.
    if ~isnan(lohi)
        x{i} = bandpass(x{i}, 1/h{i}.DELTA, lohi(1), lohi(2), popas(1), popas(2), ...
                        'butter');

        % % Despite preconditioning, filtering can still introduce edge
        % % artifacts. Remove 1% from each end of trace.
        % len_cut = 0.01 * length(x{i});
        % x{i}(1:len_cut) = NaN;
        % x{i}(end-len_cut:end) = NaN;

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
    F.pltr(i) = plot(F.ax, xax{i}, ampfac * x{i} + dist(i));
    F.pltx(i) = text(F.ax, 0, dist(i), h{i}.KSTNM);
    F.pltx(i).Color = F.pltr(i).Color;

end
F.ax.Box = 'on';
F.ax.TickDir = 'out';
grid(F.ax, 'on')

% Parse event info.  Event time is the same for all because it is the
% same event.
EQ1 = EQ{1}(1);
evttime = EQ1.PreferredTime;
magtype = EQ1.PreferredMagnitudeType;
if ~strcmpi(magtype(1:2), 'mb')
    magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', upper(magtype(1)), ...
                     lower(magtype(2)), EQ1.PreferredMagnitudeValue);

else
    magstr = sprintf('\\textit{%s}$_{\\mathrm{%s}}$ %2.1f', lower(magtype(1)), ...
                     lower(magtype(2:end)), EQ1.PreferredMagnitudeValue);

end
depthstr = sprintf('%2.1f km depth', EQ1.PreferredDepth);
locstr = titlecase(EQ1.FlinnEngdahlRegionName, {'of'});
F.tl = title([magstr ' ' locstr ' at ' depthstr]);

% Add labels.
current_xlim = get(F.ax, 'XLim');
current_ylim = get(F.ax, 'YLim');
if strcmpi(alignon, 'atime')
    % XLabel specific to aligning on first-arrival.
    F.xl = xlabel(sprintf('Time relative to first-arriving phase'));
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
        if ~isempty(tt(i).time)
            F.ph(i) = plot(F.ax, tt(i).time, tt(i).distance, 'LineWidth', ...
                       1, 'LineStyle', '-');
            phases_plotted = [phases_plotted strrep(tt(i).phaseName, 'kmps', ' km/s')];

        else
            warning('Requested phase ''%s'' not plotted (empty taupCurve)\n', tt(i).phaseName)

        end
    end

    % XLabel specific to aligning on event-rupture time.
    F.xl = xlabel(sprintf('Time relative to %s UTC (s)', datestr(evttime)));
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
    [F.lghz, F.txhz] = textpatch(F.ax, 'SouthEast', sprintf('%.2f--%.2f Hz', ...
                                 lohi), F.xl.FontSize, 'Times', true);

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
