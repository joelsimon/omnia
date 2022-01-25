function [req_str, start_date, req_sec, tt, end_date] = ...
             reqphasedatetime(evt_date, evt_dep, evt_latlon, sta_latlon, phases, req_date, buf_secs)
% [req_str, start_date, req_sec, tt, end_date] = ...
%              REQPHASEDATETIME(evt_date, evt_dep, evt_latlon, sta_latlon, phases, req_date, buf_secs)
%
% Like `reqphasetime` except the inputs can be any combination of phases and/or
% datetimes, the earliest and latest of which are retained to compute the request duration.
%
% Input:
% evt_date     Event origin time as datetime
% evt_dep      Event depth in km
% evt_latlon   Event latitude and longitude as 1x2 array
% sta_latlon   Station latitude and longitude as 1x2 array
% phases       Comma-separated phase list, or [] (or '')
% req_date     Datetime array of dates of interest (e.g., the event date),
%                  or [] (or datetime('NaT', 'TimeZone', 'UTC'))
% buf_secs*    1x2 array of seconds (numeric; not of Class 'duration')
%                  to start(end) before(after) first(last) phase
% Output:
% req_str      Cell array of timing strings formatted for "mermaid REQUEST:"
%                  (e.g., "2020-10-19T21_04_44,1903")
% start_date   Starttime of request, as datetime
% req_sec      Duration of request (in seconds) as double
% tt           TaupTime structure of first(last) retained phase
% end_date     Endtime of request, as datetime
%
% *Both times must be positive; buf_secs = [60 120] means "request from 60
%  seconds BEFORE the first phase to 120 seconds AFTER the last phase"
%
% Ex1: Request from event to 5 min. after T-wave for station in Portland, OR (IRIS event 1141196)
%    evt_date = iso8601str2date('2021-05-07T04:25:31Z');
%    evt_dep = 35.0;
%    evt_latlon = [-25.6649 -175.8501];
%    sta_latlon = [+45.5152 -122.6784];
%    phases = '1.5kmps';
%    req_date = evt_date;
%    buf_secs = [0 5*60];
%    REQPHASEDATETIME(evt_date, evt_dep, evt_latlon, sta_latlon, phases, req_date, buf_secs)
%
% Ex2: Inputs of Ex1, except request using phases only and without a time buffer
%    phases = '4kmps, 1.5kmps';
%    req_date = [];
%    buf_secs = [0 0];
%    REQPHASEDATETIME(evt_date, evt_dep, evt_latlon, sta_latlon, phases, req_date, buf_secs)
%
% Ex3: Inputs of Ex1, except request using datetimes only and without a time buffer
%    phases = [];
%    req_date = [evt_date  evt_date+hours(5.5)];
%    buf_secs = [0 0];
%    REQPHASEDATETIME(evt_date, evt_dep, evt_latlon, sta_latlon, phases, req_date, buf_secs)
%
% See also: reqphasetime.m, reqdateduration.m, reqdate.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Jan-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default outputs
req_str = {};
start_date = datetime('NaT', 'TimeZone', 'UTC');
req_sec = [];
tt = [];
end_date = datetime('NaT', 'TimeZone', 'UTC');

% First determine the start and end datetimes using just the requested phases.
% Set `buf_secs=0` here because we want to add that time buffer only AFTER
% recalculating with requested datetimes.
all_datetimes = [];
if ~isempty(phases)
    [~, ph_start_date, ~, tt, ph_end_date] = ...
        reqphasetime(evt_date, evt_dep, evt_latlon, sta_latlon, phases, [0 0]);
    all_datetimes = [all_datetimes ph_start_date(1) ; ph_end_date(end)];

end

% Add any requested input datetimes to the combined datetime list
% (this way avoids a default a NaT with a UTC timezone).
if ~isempty(req_date)
    % `req_date` is not necessarily sorted like `ph_*_date`, above
    all_datetimes = [all_datetimes ; min(req_date) ; max(req_date)];

end

% Compute the request start/end dates using the earliest/latest retained dates.
start_date = min(all_datetimes);
end_date = max(all_datetimes);

% Subtract/buffer times to star/end dates.
start_date = start_date - seconds(buf_secs(1));
end_date = end_date + seconds(buf_secs(2));

% Format as required for .cmd file, e.g.
% "mermaid REQUEST:2018-07-28T22_56_20,180,5"
% possibly split over multiple lines if long duration
[req_str, start_date, req_sec, end_date] = reqdateduration(start_date, end_date);
