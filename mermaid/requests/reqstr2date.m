function [start_date, end_date] = reqstr2date(str)
% [start_date, end_date] = REQSTR2DATE(str)
%
% Convert "mermaid REQUEST ..." cmd-file string to start and end datetimes.
%
% Input:
% str           Full request from .cmd file, e.g.,
%                   'mermaid REQUEST:2023-09-15T04_33_55,420,-1'
%
% Output:
% start_date    Datetime of start of request
% end_date      Datetime of end of request
%
% Ex:
%    [start_date, end_date] = REQSTR2DATE('mermaid REQUEST:2023-09-15T04_33_55,420,-1')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Jul-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

time_str = fx(strsplit(str, ':'), 2);
time_str = strsplit(time_str, ',');
date_str = time_str{1};
dur_str = time_str{2};

date_fmt = 'uuuu-MM-dd''T''HH_mm_ss';
start_date = datetime(date_str, 'InputFormat', date_fmt, 'TimeZone', 'UTC');
end_date = start_date + seconds(str2num(dur_str));
