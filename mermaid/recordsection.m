function [F, EQ, sac] = recordsection(id, lohi, alignon, ampfac, ...
                                      revdir, procdir, normlize)
% [F, EQ, sac] = RECORDSECTION(id, lohi, alignon, ampfac, ...
%                              revdir, procdir, normlize)
%
% Plots a record section of all MERMAID seismograms that recorded the
% same event, read from 'identified.txt', output from evt2txt.m
%
% Input:
% id        Event identification number (def: 10948555)
% lohi      Bandpass corner frequencies in Hz, or
%              NaN to plot raw seismograms  (def: [2.5 5])
% aligon    'etime': t=0 at event rupture time (def: etime)
%           'atime': t=0 at theoretical first arrival
%                    for every seismogram*
% ampfac    Nondimensional amplitude multiplication factor (def: 3)
% revdir    Path to 'reviewed' directory
%                (def: $MERMAID/events/)
% procdir   Path to 'processed' directory
%                (def: $MERMAID/processed/)
% normlize  true: normalize each seismogram against itself (def: true)
%                 (removes 1/sqrt(dist) amplitude decay)
%           false: normalize each seismogram against ensemble
%                  (preserves 1/sqrt(dist) amplitude decay)
%
% Output:
% F        Structure with figure handles and bits
% EQ       EQ structure, as returned found with sac2evt.m
% sac      SAC files whose traces are plotted
%
% *Travel time are not plotted if alignon='atime'. Also note that a
% vertical line at 0 seconds does not necessarily correspond to the
% same phase / phase branch across different seismograms.  I.e., the 0
% time for each seismogram is individually set to its first arrival,
% even if that first-arriving phase is different from the
% first-arriving phase of other seismograms plotted.  In the vast
% majority of cases the first-arriving phase be the same across all
% seismograms, but this is something to be aware of. Overlaid travel
% time curves for 'atime' option are on the wish list.
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
% Last modified: 02-Mar-2019, Version 2017b

% Wish list:
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
defval('id', 10948555)
defval('lohi', [2.5 5]);
defval('alignon', 'etime')
defval('ampfac', 3)
defval('revdir', fullfile(getenv('MERMAID'), 'events'))
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))
defval('normlize', true)

% Assumes Princeton-owned, third-generation MERMAID float SAC file
% naming convention (NOT older, GeoAzur SAC files).  Assuming
% identified.txt is formatted such that:
% (1) SAC filename is first column,
% (2) event ID is last column,
% (3) every line is formatted identically,
% (4) the column separator is a space,
% this method of arbitrary reading should be robust.
% See evt2text.m for details of 'textfile' write.
textfile = fullfile(revdir, 'reviewed', 'identified', 'txt', 'identified.txt');
textlines = readtext(textfile);
columnsep = strfind(textlines{1}, ' ');

% Don't add +1 to columnsep(end) here because that +1 might include
% an asterisk "*", indicating possible multiple events
eventid_index = [columnsep(end):length(textlines{1})];

% Find the lines in identified.txt which include that event
% identification number.
id = num2str(id);
num_matches = 0;
for i = 1:length(textlines)
    eventid{i} = strtrim(textlines{i}(eventid_index));
    if strcmp(eventid{i}, id)
        num_matches = num_matches + 1;
        sac{num_matches} = strtrim(textlines{i}(1:columnsep(1)));

        if strcmp(eventid{i}(1), '*')
            warning(['%s may be contain signals from multiple ' ...
                     'earthquakes'], sac{i})

        end
    end
end
if ~num_matches
    error('No matching event id: %s', id)

end

% Generate figure window.
F.f = figure;
F.ax = axes(F.f);
hold(F.ax, 'on');

phase_cell = {};
for i = 1:length(sac)
    % Retrieve the full path to the SAC file/
    fullpath_sac{i} = fullsac(sac{i}, procdir);

    % Retrieve the event data associated with that SAC file, as
    % found through sac2evt.m
    EQ{i} = getevt(fullpath_sac{i}, revdir);

    % Parse the event info.
    evtdate = EQ{i}(1).TaupTimes(1).arrivaldatetime;
    dist(i) = EQ{i}(1).TaupTimes(1).distance;
    phase_cell = [phase_cell {EQ{i}(1).TaupTimes.phaseName}];

    % Read the SAC data.
    [x{i}, h{i}] = readsac(fullpath_sac{i});
    seisdate{i} = seistime(h{i});

    switch lower(alignon)
      case 'etime'
        % t = 0 at event rupture time (add travel time to time
        % series and subtract offset from arrival to start of seismogram)
        offset = EQ{i}(1).TaupTimes(1).truearsecs - EQ{i}(1).TaupTimes(1).pt0;
        pt0 = EQ{i}(1).TaupTimes(1).time  - offset;
        xlstr  = 'event rupture';

      case 'atime'
        % t = 0 at first phase arrival (subtract it from time series).
        pt0 = -(EQ{i}(1).TaupTimes(1).truearsecs - EQ{i}(1).TaupTimes(1).pt0);
        xlstr = 'theoretical first arrival';

      otherwise
        error('Please specify either ''etime'' or ''atime'' for input ''alignon''.')

    end
    % Generate an x-axis.
    xax{i} = xaxis(length(x{i}), h{i}.DELTA, pt0);

    % Filter, possibly.
    if ~isnan(lohi)
        x{i} = bandpass(x{i}, 1/h{i}.DELTA, lohi(1), lohi(2));

        % Bandpassing leaves some edge artifacts. I could taper or otherwise
        % preprocess the time series but given that this script is to
        % display, and not otherwise analyze the data, I will simply
        % remove some offending-samples from the start and end of the
        % seismogram.  Do this before normalizing so the large
        % spurious signals are removed.
        x{i}(1:100) = NaN;
        x{i}(end-100:end) = NaN;
        
    end

end
% This is the max amplitude across all seismograms (i.e., likely the
% one with the shortest epicentral distance, ignoring propagation
% patterns etc.) and may be used below to normalize but maintain
% distance decay.
maxx = max(cellfun(@(xx) max(abs(xx)), x));

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
    floatnum = fx(strsplit(sac{i}, '.'), 2);
    floatnum = floatnum(1:2);

    F.pltr(i) = plot(xax{i}, ampfac * x{i} + dist(i));
    F.pltx(i) = text(min(xax{i}), dist(i), num2str(floatnum));
    F.pltx(i).Color = F.pltr(i).Color;

end
F.ax.Box = 'on';
F.ax.TickDir = 'out';
grid(F.ax, 'on')

% Parse event info.  Event time is the same for all because it is the
% same event.
EQ1 = EQ{1}(1);
evtdate = datetime(EQ1.PreferredTime, 'InputFormat', ['uuuu-MM-dd ' ...
                    'HH:mm:ss.SSS'], 'TimeZone', 'UTC');
magstr = sprintf('M%2.1f %s', EQ1.PreferredMagnitudeValue, ...
                 EQ1.PreferredMagnitudeType);
depthstr = sprintf('%2.1f km depth', EQ1.PreferredDepth);
locstr = sprintf('%s', EQ1.FlinnEngdahlRegionName);

% Add title and labels.
hold(F.ax, 'on')
current_xlim = get(F.ax, 'XLim');
current_ylim = get(F.ax, 'YLim');
if strcmp(alignon, 'atime')
    % Title and labels specific to aligning on first-arrival.
    F.tl = title(sprintf('%s UTC %s', datestr(evtdate), EQ1.FlinnEngdahlRegionName));
    F.magtx = text(F.tl.Position(1), F.tl.Position(2), F.ax, ...
                   sprintf('M%2.1f %s at %2.1f km depth', ...
                           EQ1.PreferredMagnitudeValue, ...
                           EQ1.PreferredMagnitudeType, EQ1.PreferredDepth));
    F.xl = xlabel(sprintf('time relative to %s (s)', xlstr));
    warning(['Theoretical first arrival may not be the same phase ' ...
             'or phase branch across different seismograms'])

    F.magtx.HorizontalAlignment = 'center';

    % Add vertical line at 0 seconds.
    F.vl = plot(F.ax, [0 0], get(F.ax, 'XLim'), 'k');
    bottom(F.vl)

else
    % Compute travel time curves for the phases present.
    phase_cell = unique(phase_cell);
    phase_str = strrep(strjoin(phase_cell), ' ', ',');
    tt = taupCurve('ak135', EQ1.PreferredDepth, phase_str);

    % Overlay travel time curves.
    for i = 1:length(tt)
        F.ph(i) = plot(F.ax, tt(i).time, tt(i).distance, 'LineWidth', ...
                       1.5, 'LineStyle', '-');
        
    end
    
    % Title and labels specific to aligning on event-rupture time.
    F.tl = title([magstr ' ' locstr ' at ' depthstr]);
    timstr = sprintf('%s UTC', EQ1.PreferredTime(1:19));
    F.xl = xlabel(sprintf('time since %s (s)', timstr));
    F.lg = legend(F.ph, phase_cell, 'AutoUpdate', 'off');

end
hold(F.ax, 'off')
set(F.ax, 'XLim', current_xlim);
set(F.ax, 'YLim', current_ylim);

% Annotate figure with bandpass corner frequencies and event id number.
if ~isnan(lohi)
    [F.bhul, F.thul] = boxtexb('ul', F.ax, sprintf('%.2f~-~%.2f Hz', lohi), F.xl.FontSize);
    F.bhul.Visible = 'off';

end
[F.bhlr, F.thlr] = boxtexb('lr', F.ax, sprintf('%s', id), F.xl.FontSize);
F.bhlr.Visible = 'off';

% Final cosmetics.
F.yl = ylabel(F.ax, 'distance ($^{\circ}$)');
F.tl.FontWeight = 'normal';
latimes

% Send travel time curves to the bottom.
botz(F.ph, F.ax);
