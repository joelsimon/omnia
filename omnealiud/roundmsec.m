function tstr = roundmsec(tstr)
% tstr = ROUNDMSEC(tstr)
%
% Round milliseconds to nearest centisecond and rewrite as 3-digit milliseconds.
%
% Input:
% tstr       Datestring with three decimal places
%
% Output:
% tstr       Datestring rounded to two decimal places
%
%
% Ex:
%    ROUNDMSEC('2018-07-06T01:49:30.604')
%    ROUNDMSEC('2018-07-06T01:49:30.605')
%    ROUNDMSEC('2018-07-06T01:49:59.994')
%    ROUNDMSEC('2018-07-06T01:49:59.995')
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 08-Jun-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

if ~strcmp(tstr(end-3), '.')
    error('String must have three decimal places')

end

% Convert to unix time and round to centiseconds.
secs = posixtime(fdsnstr2date(tstr));
round_secs = round(secs, 2);

% Covert unix time back to datetime, and covert back to FDSN-formatted string.
round_date = datetime(round_secs, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
tstr = fdsndate2str(round_date);
