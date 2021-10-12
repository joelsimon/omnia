function [req_str, start_date, req_secs, tt] = reqphasetime(evt_date, evt_dep, ...
                                                      evt_latlon, sta_latlon, ...
                                                      phases, buf_secs)
% [req_str, start_date, req_secs, tt] = REQPHASETIME(evt_date, evt_dep, ...
%                                         evt_latlon, sta_latlon, phases, buf_secs)
%
% Return start time and duration strings for "mermaid REQUEST" for .cmd file,
% given source/receiver information and phase list of interest.
%
% Inputs:
% evt_date     Event origin time as datetime
% evt_dep      Event depth in km
% evt_latlon   Event latitude and longitude as 1x2 array
% sta_latlon   Station latitude and longitude as 1x2 array
% phases       Comma-separated phase list
% buf_secs*    Seconds (numeric; not of Class 'duration') to
%                 start(end) before(after) first(last) phase
%
% Outputs:
% req_str      Timing string formatted for "mermaid REQUEST:"
%                  (e.g., "2020-10-19T21_04_44,1903")
% start_date   Starttime of request, as datetime
% req_secs     Length of request (in seconds) as double
% tt           TaupTime structure of first(last) retained phase
%
% * Both times must be positive; buf_secs = [60 120] means "request from 60
%   seconds BEFORE the first phase to 120 seconds AFTER the last phase"
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 11-Oct-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default outputs
starttime = [];
req_secs = [];
warn = false;

% To avoid ambiguity both buffer times must be positive; the first goes
% backwards in time from the start and the second goes forward from the end
if ~all(buf_secs >= 0)
    error('Both times in `buf_secs` must be positive')

end

% Compute travel times.
tt = taupTime('ak135', evt_dep, phases, 'evt', evt_latlon, 'sta', sta_latlon);
if isempty(tt)
    warning('Requested phases do not exist at specific source/receiver geometry')
    return

end

% Retain only the R1 path in the case of *kmps phases (e.g., 3.5kmps surface
% waves and 1.5kmps T waves).
R1_dist = tt(1).distance;
tt(find([tt.distance] ~= R1_dist)) = [];

% Retain only the first and last phases, e.g. in the case of multiple P wave
% arrivals (NB, if length(tt) == 1 or 2 this does not alter the structure).
tt(2:end-1) = [];

% Find datetime of first and last phase arrivals, which may be the same in the
% case of a single retained phase.
arr_date(1) = evt_date + seconds(tt(1).time);
if length(tt) > 1
    arr_date(2) = evt_date + seconds(tt(2).time);

else
    arr_date(2) = arr_date(1);

end

% Subtract and add buffer times to arrival datetimes.
start_date = arr_date(1) - seconds(buf_secs(1));
end_date = arr_date(2) + seconds(buf_secs(2));

% Format as required for .cmd file, e.g.
% "mermaid REQUEST:2018-07-28T22_56_20,180,5"
req_secs = ceil(seconds(end_date - start_date));
req_str = sprintf('%s,%i', reqdate(start_date), req_secs);
