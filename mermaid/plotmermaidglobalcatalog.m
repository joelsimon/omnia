function [F1, ha1, F2, ha2] = plotmermaidglobalcatalog(ha1, ha2, mercatfile, statdate, floatnums)
% [F1, ha1, F2, ha2] = ...
%     PLOTMERMAIDGLOBALCATALOG(ha1, ha2, mercatfile, statdate, floatnums)
%
% PLOTMERMAIDGLOBALCATALOG generates a stem plot displaying MERMAID
% event detection through time, and a histogram showing detection
% statistics broken down by float number, considering a given
% date-range.
%
% Input:
% ha1          Axes handle for date stem plot (def: create new)
% ha2          Axes handle for float count histogram (def: create new)
% mercatfile   Text file written by writemermaidglobalcatalog.m,
%                  annotating the global seismic catalog with
%                  MERMAID positive IDs
%                  (def: $MERMAID/events/reviewed/identified/txt/M6_DET.txt)
% statdate     Beginning and end datetime to consider for statistics, inclusive
%                 (def: [eqtime(1) , eqtime(end)])*
% floatnums    Array of specific float numbers considered in
%                  writemermaidglobalcatalog.m (def: [8:13 16:25])**
% Output
% F1           Structure with ha1 handle bits
% ha1          Stem plot axes handle
% F2           Structure with ha2 handle bits
% ha2          Histogram axes handle.
% N            Total unique events (not just those ID'd) within the time period
% ID           Number of unique events ID'd within time period
% E            Mean number of reports (event detections) per MERMAID
%                  within the time period
% P            Probability any given MERMAID reported any given event
%                  within the time period
%
% *PLOTMERMAIDGLOBALCATALOG always plots the entire time series from
% the first to last eqtime in mercatfile. However, statistics may be
% collected within any date range contained within that file.  E.g.,
% if one wants to only plot and analyze one month of data, set the
% statdate as input and adjust the XLim after execution.
%
% **Must be monotonically increasing, positive integer array
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-Mar-2020, Version 2017b on MACI64

% Default.
defval('ha1', [])
defval('ha2', [])
defval('statdate', NaT('TimeZone', 'UTC'))
defval('mercatfile', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                              'identified', 'txt', 'M6_DET.txt'))
defval('floatnums', [8:13 16:25])

% Read the data from the relevant MERMAID catalog file.
num_floats = length(floatnums);
[eqtime, eqlat, eqlon, eqdepth, eqmag, eqid, mertot, mernum] = ...
    readmermaidglobalcatalog(mercatfile, num_floats);

% Convert EQ time strings to datetimes.
eqtime = fdsnstr2date(eqtime);

% These are the indices of the data returned that fall within the requested statdate.
if isnat(statdate)
    statdate(1) = eqtime(1);
    statdate(2) = eqtime(end);

end

% Event indices within the requested time range (inclusive).
idx = find(isbetween(eqtime, statdate(1), statdate(2)));

% Event indices outside the requested time range.
all_idx = 1:length(eqtime);
idx_out = setdiff(all_idx', idx);

% Events within time range.
pos_id = intersect(find(mertot), idx);
null_id = setdiff(idx, pos_id);

% Events outside time range.
pos_id_out = intersect(find(mertot), idx_out);
null_id_out = setdiff(idx_out, pos_id_out);

%% Axis 1: stem plot
if isempty(ha1)
    F1.f = figure;
    ha1 = gca;

else
    F1.f = ha1.Parent;

end

% Find the event(s) reported by the most MERMAIDs.  These indices
% match those of eqtime, eqid etc.  They are not the same index-base
% as mertot(idx), which includes only those in the time window of
% interest, though I'm careful in the next line to only search for
% maximum-event reporst within the time window of interest
% (mertot(idx)).
max_mertot_idx = find(mertot == max(mertot(idx)));
max_mertot_eqtime = eqtime(max_mertot_idx);
max_mertot_eqid = eqid(max_mertot_idx);

% Generate the stem plot showing number of MERMAIDS reporting event
% through time.  Missed events are labeled with an 'x' at 0 on the
% y-axis.  Any events outside the requested time range are plotting in
% gray, while those within the time range are plotting in black.
hold(ha1, 'on')
F1.pl_pos = stem(ha1, eqtime(pos_id), mertot(pos_id), 'k', 'MarkerFaceColor', 'k');
F1.pl_null = stem(ha1, eqtime(null_id), repmat(-1.25, size(mertot(null_id))), 'kx', 'MarkerSize', 4);
F1.pl_pos_out = stem(ha1, eqtime(pos_id_out), mertot(pos_id_out), 'Color', [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5]);
F1.pl_null_out = stem(ha1, eqtime(null_id_out), repmat(-1.25, size(mertot(null_id_out))), 'x','MarkerSize', 4, 'Color', [0.5 0.5 0.5]);
hold(ha1, 'off')

% Find the F.pl_pos indices that correspond to the max so I can
% highlight the one(s) I want in post.
mag_unit = str2num(mercatfile(end-8));
if ~isempty(max_mertot_idx)
    fprintf('\n\nMAGNITUDE %i-%i.9: max. of %i MERMAID identification(s) per event\n\n', mag_unit, mag_unit, max(mertot(idx)))
    for i = 1:length(max_mertot_eqtime);
        fprintf('F1.pl_pos.XData(%i)\n', ...
                find(datenum(F1.pl_pos.XData) == datenum(max_mertot_eqtime(i)))); % This will be unique so find is okay.
        fprintf('Date: %s\nID:   %s\n\n', datestr(max_mertot_eqtime(i)), max_mertot_eqid{i})

    end
end

% Label the axes, considering only requested time range.
num_events = length(idx);
num_events_ID = length(pos_id);
perc_events_ID = (num_events_ID / num_events) * 100; % considering all floats
num_mermaids_reporting_per_event = mertot(pos_id);
tot_event_reports = sum(num_mermaids_reporting_per_event);

% Mean number of unique events reported per MERMAID over time period.
mean_events_ID_per_mermaid = tot_event_reports / num_floats;
mean_num_mermaids_reporting_per_event = mean(num_mermaids_reporting_per_event);

% Probability any given MERMAID will report any given event over the time period.
P = mean_events_ID_per_mermaid / num_events;

F1.tl = title(ha1, sprintf('%i unique events (%i identified [%.1f%s])', num_events, num_events_ID, perc_events_ID, '\%'));
F1.yl = ylabel(ha1, sprintf('MERMAID\nidentifications'));
F1.xl = xlabel(ha1, 'Event date');

%ha1.YLim = [0 num_floats];
ha1.YLim = [-2.5 num_floats];

%% Axis 2: histogram;
if isempty(ha2)
    F2.f = figure;
    ha2 = gca;

else
    F2.f = ha2.Parent;

end

% This adjusts the histogram x-axis by overwriting the actual float
% numbers (possibly with missing values, e.g. float 14_) into a set
% that monotonically increases by 1 integer, while keeping track of
% what the adjusted number actually maps too.
all_nums = [mernum{intersect(pos_id, idx)}];
dnums = diff(floatnums);
adj_idx = find(dnums ~= 1);

% This subtracts missing float number(s) from the set. E.g., if
% floatnums = [1 2 3 6 7 10], it will adjust s.t. the floatnums are [1
% 2 3 4 5 6]. This means there is no gap in the histogram x-axis
rm_tot = 0;
for i =  1:length(adj_idx)
    adj_amount = dnums(adj_idx(i)) - 1;
    rm_tot = rm_tot + adj_amount;

    start_adj = floatnums(adj_idx(i));
    if i ~= length(adj_idx)
        end_adj = floatnums(adj_idx(i+1));

    else
        end_adj = floatnums(end);

    end

    all_nums(find(all_nums > start_adj & all_nums <= end_adj)) = ...
        all_nums(find(all_nums > start_adj & all_nums <= end_adj)) - rm_tot;

end

% Generate the histogram.
F2.h = histogram(ha2, all_nums, 'BinMethod', 'Integer', 'FaceColor', 'k');
F2.xl = xlabel(ha2, 'MERMAID');
F2.yl = ylabel(ha2, sprintf('Events identified'));

% Update the x-axis in case labels need to be remapped after adjusting
% for missing float numbers.
ha2.XTick = [floatnums(1) : floatnums(1) + num_floats - 1];
ha2.XTickLabel = sprintfc('%d', floatnums); % undocumented function
F.mtx = mean(all_nums);

ha2.XLim = [floatnums(1)-.5 floatnums(1)+num_floats-.5];
ha2.YLim = [0 length(idx)];

F2.tl = title(ha2, sprintf(['%i identifications (average of %i ' ...
                    'per MERMAID)'], tot_event_reports, ...
                           round(mean_events_ID_per_mermaid)));

% Cosmetics.
box(ha1, 'on')
longticks(ha1, 2)
box(ha2, 'on')
longticks(ha2, 2)

latimes(F1.f)
latimes(F2.f)

fprintf(['\n\nConcerning the magnitude range \\M%i--%i.9: there were %i unique ' ...
         'global events, of which %i (%4.1f%s) were positively identified by ' ...
         'at least one of %i \\mermaidsb.\nIf an event was identified, there ' ...
         'were on average %.1f \\mermaids reporting that unique event.\nIn ' ...
         'total, %i event identifications were reported by %i \\mermaidsb, ' ...
         'meaning that on average each \\mermaid reported %.1f unique ' ...
         'events.\n\n'], mag_unit, mag_unit, num_events, num_events_ID, ...
        perc_events_ID, '\%', num_floats, mean_num_mermaids_reporting_per_event, ...
        tot_event_reports, num_floats, mean_events_ID_per_mermaid)
