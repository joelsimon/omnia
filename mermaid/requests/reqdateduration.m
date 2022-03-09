function [req_str, start_date, req_sec, end_date] = reqdateduration(start_date, end_date)
% [req_str, start_date, req_sec, end_date] = REQDATEDURATION(start_date, end_date)
%
% Returns partial .cmd request*, the start date and duration only, formatted
% properly and split into multiple requests if the duration is greater than 1800
% seconds (the maximum-allowed request duration).  To be safe, returns request
% lines split into chunks 95% of allowed maximum duration (1710 seconds).
%
% Input:
% start_date    Datetime of start of request
% end_date      Datetime of end of request
%
% Output:
% req_str       Cell array of start date and duration, formatted for .cmd
%                   "mermaid REQUEST...", possibly split across multiple lines
% start_date    Datetime array of start of each request line
% req_sec       Double array duration in seconds of each request line
% end_date      Datetime array of end of each request line
%
% *E.g. if the full request is "mermaid REQUEST:2018-05-14T22_14_00,120,-1",
%  REQDATEDURATION only returns "2018-05-14T22_14_00,120"
%
% Ex1: Request 0.25 hours of data; single-line request okay
%    start_date = iso8601str2date('2000-01-01T00:00:00Z');
%    end_date = start_date + hours(0.25);
%    [req_str, start_date, req_sec, end_date] = REQDATEDURATION(start_date, end_date)
%
% Ex2: Request 5.25 hours of data; must split request over multiple lines
%    start_date = iso8601str2date('2000-01-01T00:00:00Z');
%    end_date = start_date + hours(5.25);
%    [req_str, start_date, req_sec, end_date] = REQDATEDURATION(start_date, end_date)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Jan-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Sanity.
if ~isdatetime(start_date) || ~isdatetime(end_date)
    error('Both inputs must be datetimes')

end

% Request duration in seconds.
req_duration = ceil(seconds(end_date - start_date));

% Manual Réf : 452.000.852 Version 00 states a max duration of 1800 seconds
% (let's use 95% of that quoted max just to be safe?).
max_duration = 1800;
%max_duration = floor(max_duration * 0.95);

% If request less than the maximum duration, return in a single line.
if req_duration < max_duration
    req_sec = ceil(seconds(end_date - start_date));
    req_str = {sprintf('%s,%i', reqdate(start_date), req_sec)};

else
    % Otherwise split across multiple requests, the next starting where the previous
    % ends, with durations equal to the maximum-allowed request duration.

    % First maximum-duration line (there may only be one).
    i = 1;
    line_start(i) = start_date;
    req_sec(i) = max_duration;
    req_str{i} = sprintf('%s,%i', reqdate(line_start(i)), req_sec);
    line_end(i) = line_start(i) + seconds(req_sec);

    % Maximum-duration lines 2 through N, if necessary.
    num_max_lines = floor(req_duration / max_duration);
    if num_max_lines >= 2
        for i = 2:num_max_lines
            line_start(i) = line_end(i-1);
            req_sec(i) = max_duration;
            req_str{i} = sprintf('%s,%i', reqdate(line_start(i)), req_sec(i));
            line_end(i) = line_start(i) + seconds(req_sec(i));

        end
    end

    % Finish the multiline request with whatever remaining time is leftover (if any;
    % the request may be an integer multiple of maximum-allowed time) after
    % requesting maximum-duration chunks.
    line_start(i+1) = line_end(i);
    req_sec(i+1) = ceil(seconds(end_date - line_start(i+1)));
    if req_sec > 0
        req_str{i+1} = sprintf('%s,%i', reqdate(line_start(i+1)), req_sec(i+1));
        line_end(i+1) = line_start(i+1) + seconds(req_sec(i+1));
    end

    % Verify the numbers all sum as they should.
    if abs(seconds(line_start(1) - start_date)) > 1  ...
            || abs(seconds(line_end(end) - end_date)) > 1
        error('Line dates do not start/end correctly')

    end

    req_str = req_str';
    start_date = line_start';
    end_date = line_end';
    req_sec = req_sec';

end
