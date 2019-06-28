function [F, CP, tt] = plotcpmerazur(sacfile, inputs, conf, domain)
% [F, CP, tt] = PLOTCPMERAZUR(sacfile, inputs, conf, domain)
%
% PLOTCPMERAZUR plots GeoAzur MERMAID seismograms with arrival times
% and event metadata from the public catalog, along with changepoint.m
% arrival times.
%
% The phase reported in GeoAzur's events.txt is highlighted in the
% figure with a prefix asterisks.
%
% Input:
% sacfile   SAC file name (def: 'm35.20140915T080858.sac')
% inputs    changepoint.m inputs structure (def: cpinputs)
% conf      logical true to compute confidence intervals 
%               (def: -1)
% domain    'time' or 'time-scale', for changepoint
%
% Output:
% F        Struct of figure handles and bits
% CP       Output of changepoint.m, see there
% tt       Output of arrivaltime.m, see there
%
% Ex:
%    sacfile = 'm35.20140915T080858.sac';
%    [F, CP, tt] = PLOTCPMERAZUR(sacfile)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Jun-2019, Version 2017b

% Defaults.
defval('sacfile', 'm35.20140915T080858.sac')
defval('inputs', cpinputs)
defval('conf', -1)
defval('domain', 'time')

% Read specific SAC file data and header
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

% 'grep' the 'events.txt' file(s) for the phase name GA reports is
% associated with this event.
[~, evtline] = mgrep(evtfile, sacfile);

% N.B.: While previously the global 'events.txt' file and the
% individual floats' 'm??_events.txt' files differed, as of the
% current fetch Fri Mar 22 15:09:54 UTC 2019, they are
% identical. Therefore you only have to search one and not both for
% the proper event line.  See gafloats.m

% Parse phase from matching line in 'events.txt'.
ga_phase = purist(strtrim(evtline{1}(103:110)));
def_phase = defphases;

% If ga_phase is not within def_phases list, add it.
if isempty(strfind(def_phase, ga_phase))
    def_phase = [def_phase ', ' ga_phase];

end

% TauP travel time for GA phase and all default phases I search for.
tt = arrivaltime(h, evtdate, [h.EVLA h.EVLO], 'ak135', h.EVDP, def_phase);

if isempty(tt)
    % If ak135 fails (e.g., 'm33.20150530T113345.sac') try with a
    % different velocity model.  In this case the GA phase is 'Pdiff'.
    % For reference, in ak135, the first arriving 'P' phase arrives
    % 0.25 seconds after the 'Pdiff' phase as computed below using
    % iasp91.
    tt = arrivaltime(h, evtdate, [h.EVLA h.EVLO], 'iasp91', ...
                     h.EVDP, def_phase);
    
    if ~isempty(tt)
        warning('Used iasp91 velocity model for %s.', sacfile)

    else
        keyboard
        error

    end
end

% The number of wavelet scales to decompose the seismogram is based on
% the sampling frequency. See discussion in header.
fs = 1/h.DELTA;
if round(fs) == 5
    n = 3;
    
elseif round(fs) == 20
    n = 5;

end

% Compute both multiscale arrival times
offset = tt(1).truearsecs - tt(1).pt0;
adjusted_pt0 = tt(1).time  - offset;
CP = changepoint(domain, x, n, h.DELTA, adjusted_pt0, 1, inputs, conf);
F = plotchangepoint(CP, 'all', 'ar', true, true);

% Shrink the distance between each subplot -- 'multiplier' is adjusted
% depending on the number of subplots (the number of wavelet
% scales plotted).
multiplier = 0;
switch n
  case 3
    shrink(F.ha, 1, 1.53)
    for l = 1:length(F.ha)
        multiplier = multiplier + 1;
        movev(F.ha(l), multiplier * 0.08)
        
    end
    movev(F.ha, -0.1)
    
  case 5
    for l = 1:length(F.ha)
        multiplier = multiplier + 1;
        movev(F.ha(l), multiplier * 0.02)
        
    end
    movev(F.ha, -0.1)
    
    
    
end

for i = 1:length(F.ha) - 1
    F.ha(i).XTickLabels = {};

end

% The axes have been shifted -- need to adjust the second (AIC) adjust and re-tack2corner the annotations.
for l = 1:length(F.ha)
    F.ha2(l).Position = F.ha(l).Position;
    
end

% Update seismogram x-axis with adjusted, time-since-event x-axis.
ax = F.ha(1);
hold(ax, 'on')    

for i = 1:length(tt)
    if mod(i, 2) == 0
        height = -1.5;

    else
        height = 1.5;

    end
    time_since_evt = adjusted_pt0 + tt(i).truearsecs;
    vl1(i) = plot(ax, repmat(time_since_evt, [1 , 2]), ax.YLim, ...
                  'k', 'LineWidth', 1.5);
    phstr = sprintf('%s', tt(i).phaseName);
    if strcmp(phstr, ga_phase)
        phstr = strcat('*', phstr);

    end
    text(ax, time_since_evt, height, phstr); 

end

% Pull Flinn-Engdahl region name from IRIS rather than verifying every
% region name in events.txt is correct,
region = feregion(h.EVLA, h.EVLO);
F.tl = title(ax, region, 'FontSize', 20);
F.tl.Position(2) = 1.75;
fonts = 12;

% Annotate the seismogram. Only one event reported.  All distances are the same.
hitmul = 1.25;
widmul = 0.5;
magstr = sprintf('$\\textrm{M}%2.1f$', h.MAG);
depthstr = sprintf('$%6.2f~\\textrm{km}$', h.EVDP);
diststr = sprintf('$%6.2f^{\\circ}$', tt(1).distance); 

% Order clockwise from upper left.
[F.lg(1), F.tx(1)] = textpatch(ax, 'NorthWest', magstr, 10);
[F.lg(2), F.tx(2)] = textpatch(ax, 'NorthEast', diststr, 10);
[F.lg(3), F.tx(3)] = textpatch(ax, 'SouthEast', depthstr, 10);
[F.lg(4), F.tx(4)] = textpatch(ax, 'SouthWest', strippath(sacfile), 10);

% Add time axis on bottom.
xlabel(F.ha(end), sprintf('time since %s (s)', datestr(evtdate)));

axesfs([], 10, 13)
latimes

lgtxlatimesfs([F.lg F.lgSNR], [F.tx F.txSNR], 10)
F.tl.FontSize = 20;

longticks(F.ha, 3)

% After all formatting and resizing, tack patches to the corners.
pause(0.1)  % Pause execution for a beat to allow all callbacks to update
tack2corner(F.ha(1), F.lg(1), 'NorthWest')
tack2corner(F.ha(1), F.lg(2), 'NorthEast')
tack2corner(F.ha(1), F.lg(3), 'SouthEast')
tack2corner(F.ha(1), F.lg(4), 'SouthWest')
for i = 1:length(F.lgSNR)
    tack2corner(F.ha(i + 1), F.lgSNR(i), 'SouthWest')

end
