% Script to write updated GeoAzur MERMAID catalog assuming JDS' system
% defaults.
%
% Preprocessing steps:
%
% 1) Rematch earthquakes: rematch_merazur.m
%
% 2) Review those rematches: reviewrematch_merazur.m
%
% 3) Compute and save changepoints and their confidence intervals
% writechangepoint_merazur.m
%
% Finally, run this script to produce output catalog.
%
% NB; I later realized with this formatspec that things like "-0.00" were
% printing; after the fact I replaced that with " 0.00" using `sed`.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Mar-2019, Version 2017b

clear
close all

% Load data.
base_diro = getenv('MERAZUR');
rematch_diro = fullfile(getenv('MERAZUR'), 'rematch');

% Sort SAC files based on time of first sample of seismogram.
s = mermaid_sacf;
for i = 1:length(s)
    [~, h{i}] = readsac(s{i});
    [seis_date{i}, ~, seis_datenum, ~, original_evtdate{i}] = seistime(h{i});
    first_sample(i) = seis_datenum.B;

end
[first_sample, idx] = sort(first_sample);
s = s(idx);
seis_date = seis_date(idx);

% Nab and extended eventblock for this SAC file and concentrated
% (slow, inefficient).
eb = eventblock_local(s{1});
for i = 2:length(s)
    eb  = sprintf([eb repmat('_', 1, 67) '\n\n' eventblock_local(s{i})]);

end

% GeoAzur-specific paths.
base_diro = getenv('MERAZUR');
rematch_diro = fullfile(getenv('MERAZUR'), 'rematch');
filename = fullfile(rematch_diro, 'catalog.txt');

% Grant write access to file, if write-protected.
if exist(filename, 'file') == 2
    fileattrib(filename, '+w')

end

% Save the text file.
fid = fopen(filename, 'w');
fprintf(fid, eb);
fclose(fid);

% Write protect the file.
fileattrib(filename, '-w')

% Exit with path to file just written.
fprintf('Sucess: %s\n', filename)

%________________________________________________________________________%

function eb = eventblock_local(sac)
% Local version of eventblock.m, modified to include event and phase
% information originally reported by GeoAzur.
%
% All information about the event (time, location, depth) etc. are
% taken from the SAC file's header.
%
% The only information taken from events.txt is the reported phase
% name.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Mar-2019, Version 2017b

% For tres.m; we only consider a single event associated with every
% SAC file (I've manually verified only a single match per).
multi = false;

% GeoAzur-specific paths.
base_diro = getenv('MERAZUR');
rematch_diro = fullfile(getenv('MERAZUR'), 'rematch');

% Read the data and load the saved ('final') EQ and CP structures.
[x, h] = readsac(sac);
EQ = getevt(sac, rematch_diro);
CP = getcp(sac, rematch_diro);

%______________________________________________________%
%% Event name, identification number, Flinn-Engdahl region block.

event_line = sprintf('Filename %23s\n', EQ(1).Filename);
eventid = fx(strsplit(EQ(1).PublicId, 'eventid='),  2);
id_line = sprintf('IRIS Event ID %7s %34s\n', eventid, EQ(1).FlinnEngdahlRegionName);
last_queried_line = sprintf('Last updated %10s\n\n', strrep(EQ(1).QueryTime(1:10), '-', '/'));
event_block = sprintf([event_line id_line last_queried_line]);

%______________________________________________________%
%% Date, location, depth, distance, and magnitude block.

date_header_line = '   Date       Time     Latitude Longitude  Depth Distance Magnitude\n';
date_header_line = ['         ' date_header_line];

date_fmt = ['%22s ' ...
            '%8.4f ' ...
            '%9.4f ' ...
            '%6.2f ' ...
            '%8.4f ' ...
            ' %4.1f ' ...
            '%3s\n'];

% GeoAzur reported date and time (per the SAC file's header).
[~, ~, ~, ~, ga_evtdate] = seistime(h);
ga_date_data = {pdetime2str(ga_evtdate)
                h.EVLA,
                h.EVLO,
                h.EVDP,
                h.GCARC,
                h.MAG,
                []};
ga_date_line = sprintf(date_fmt, ga_date_data{:});
ga_date_line = ['Initial: ' ga_date_line];

% Updated date and time.
updated_date_data = {strrep(EQ(1).PreferredTime(1:22), '-', '/'), ...
                    EQ(1).PreferredLatitude, ...
                    EQ(1).PreferredLongitude, ...
                    EQ(1).PreferredDepth, ...
                    EQ(1).TaupTimes(1).distance, ...
                    EQ(1).PreferredMagnitudeValue, ...
                    EQ(1).PreferredMagnitudeType};
updated_date_date_line = sprintf(date_fmt, updated_date_data{:});
updated_date_date_line = ['Updated: ' updated_date_date_line];

date_block = sprintf([date_header_line ga_date_line updated_date_date_line ...
                    '\n']);

%______________________________________________________%
%% Phase-arrival block

% GeoAzur reported phase (per the 'events.txt' file distrubted with
% the data).
evtfile = fullfile(getenv('MEREVENTS'), 'events.txt');
[~, evtline] = mgrep(evtfile, strippath(sac), 1);
ga_phase = strtrim(evtline{1}(103:110));
ga_phase_line = sprintf('GeoAzur phase pick: %s\n\n', ga_phase);

% Compute travel time residuals.
[tres_time, tres_phase, tres_EQ] = tres(EQ, CP, multi);

scales = CP.inputs.n;
phase_info_line = sprintf('JDS multiscale phase picks: %1i scales at %i Hz\n', ...
                          scales, round(1 / CP.inputs.delta));

% Parse arrivals and residuals.
phase_header_line = 'Phase  Time    Tres     SNR       Mu  2Sigma\n';

phase_fmt = ['%5s '...
             '%6.2f ' ...
             '%7.2f ' ...
             '%9.3E ' ...
             '%6.2f ' ...
             '%6.2f\n'];

for j = 1:length(CP.arsecs)
    if ~isnan(tres_phase{j})
        % Measure arrival time as offset from 0 seconds (first sample of
        % seismogram at 0 s).  This is the same convention used in
        % tres.m.
        phase_data = {tres_phase{j}, ...
                      CP.arsecs{j} - CP.inputs.pt0, ...
                      tres_time(j), ...
                      CP.SNRj(j), ...
                      CP.ci.M1(j).ave, ...
                      CP.ci.M1(j).twostd};

    else
        phase_data = {repmat(NaN, 1, 6)};

    end

    phase_data_line{j} = sprintf(phase_fmt, phase_data{:});

end

phase_block = sprintf([ga_phase_line phase_info_line phase_header_line phase_data_line{:}]);

%______________________________________________________%
%% Concatenate
eb = sprintf([event_block date_block phase_block]);
end
