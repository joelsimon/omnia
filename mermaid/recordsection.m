function [F, EQ, sac] = recordsection(id, lohi, alignon, ampfac, revdir, procdir)
% [F, EQ, sac] = RECORDSECTION(id, lohi, alignon, ampfac, revdir, procdir)
%
% revdir    Path to directory containing 'reviewed' directory
%                (def: $MERMAID/events/)
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 07-Dec-2018, Version 2017b

defval('id', 10948555)
defval('lohi', [2.5 5]);
defval('alignon', 'etime')
defval('ampfac', 3)
defval('revdir', fullfile(getenv('MERMAID'), 'events'))
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))

% So long as (1) SAC filename is first column, (2) event ID is last
% column, and (3) every line is formatted identically, this method of
% arbitrary reading should be robust.  See evt2text.m for details of
% 'textfile' write.
textfile = fullfile(revdir, 'reviewed', 'identified', 'txt', 'identified.txt');
textlines = readtext(textfile);
columnsep = strfind(textlines{1}, ' ');

% Don't add +1 to columnsep(end) here because that +1 might include
% an asterisk "*", indicating possible multiple events
eventid_index = [columnsep(end):length(textlines{1})];

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

F.f = figure;
F.ax = axes(F.f);
hold(F.ax, 'on');

phase_cell = {};
for i = 1:length(sac)
    fullpath_sac{i} = fullsac(sac{i}, procdir);

    EQ{i} = getevt(fullpath_sac{i}, revdir);
    evtdate = EQ{i}(1).TaupTimes(1).arrivaldatetime;
    dist(i) = EQ{i}(1).TaupTimes(1).distance;
    phase_cell = [phase_cell {EQ{i}(1).TaupTimes.phaseName}];
    
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
        xlstr = 'theoretical P-wave arrival';

      otherwise
        error('Please specify either ''etime'' or ''atime'' for input ''alignon''.')

    end
    xax{i} = xaxis(length(x{i}), h{i}.DELTA, pt0);

    if ~isnan(lohi)
        x{i} = bandpass(x{i}, 1/h{i}.DELTA, lohi(1), lohi(2));
        
    end


    
    % Normalize each trace.
    x{i} = norm2max(x{i});
    
    % Alternatively could normalize to the max of the set to see
    % the amplitude fall off.
    %% Uncomment this for 1/sqrt(r) amplitude fall off.
    % maxx(i) = nanmax(abs(x{i}));    
    
    % Bandpassing leaves some edge artifacts. Could taper.  Instead just
    % chopping off ends.
    x{i}(1:20) = NaN;
    x{i}(end-19:end) = NaN;

end

%% Uncomment this for 1/sqrt(r) amplitude fall off.
%maxx = max(maxx);

for i = 1:length(x)
    %% Uncomment this for 1/sqrt(r) amplitude fall off.
    %x{i} = x{i} / maxx;
    
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

EQ1 = EQ{1}(1);
% Event time is the same for all here because it's the same event.
evtdate = datetime(EQ1.PreferredTime, 'InputFormat', ['uuuu-MM-dd ' ...
                    'HH:mm:ss.SSS'], 'TimeZone', 'UTC');

magstr = sprintf('M%2.1f %s', EQ1.PreferredMagnitudeValue, ...
                 EQ1.PreferredMagnitudeType);
depthstr = sprintf('%2.1f km depth', EQ1.PreferredDepth);
locstr = sprintf('%s', EQ1.FlinnEngdahlRegionName);
timstr = sprintf('%s UTC', EQ1.PreferredTime(1:19));

% Overlay travel time curves.
current_xlim = get(F.ax, 'XLim');
current_ylim = get(F.ax, 'YLim');
%phase_cell = {EQ(1).TaupTimes.phaseName};

phase_cell = unique(phase_cell);
phase_str = strrep(strjoin(phase_cell), ' ', ',');
tt = taupCurve('ak135', EQ1.PreferredDepth, phase_str);
for i = 1:length(tt)
    F.ph(i) = plot(F.ax, tt(i).time, tt(i).distance, 'LineWidth', ...
                   1.5, 'LineStyle', '-');

end
hold(F.ax, 'off')
set(F.ax, 'XLim', current_xlim);
set(F.ax, 'YLim', current_ylim);
F.lg = legend(F.ph, phase_cell, 'AutoUpdate', 'off')

%% To be cleaned up!!!
if strcmp(alignon, 'atime')

    F.tl = title(sprintf('%s UTC %s', datestr(evtdate), EQ1.FlinnEngdahlRegionName));
    F.magtx = text(F.tl.Position(1), F.tl.Position(2), F.ax, ...
                   sprintf('M%2.1f %s at %2.1f km depth', ...
                           EQ1.PreferredMagnitudeValue, ...
                           EQ1.PreferredMagnitudeType, EQ1.PreferredDepth));
    F.xl = xlabel(sprintf('time relative to %s (s)', xlstr));
    F.magtx.HorizontalAlignment = 'center';

else
    F.tl = title([magstr ' ' locstr ' at ' depthstr]);
    F.xl = xlabel(sprintf('time since %s (s)', timstr));


end

[F.bhul, F.thul] = boxtexb('ul', F.ax, sprintf('%.2f~-~%.2f Hz', lohi), F.xl.FontSize);
[F.bhlr, F.thlr] = boxtexb('lr', F.ax, sprintf('%s', id), F.xl.FontSize);

F.bhul.Visible = 'off';
F.bhlr.Visible = 'off';

F.yl = ylabel(F.ax, 'distance ($^{\circ}$)');
F.tl.FontWeight = 'normal';
latimes




