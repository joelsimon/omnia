function str = roundmsec(str)
% str = ROUNDMSEC(str)
%
% Round a datestring in millisecond precision to centisecond precision.
%
% Input:
% str       Datestring with three decimal places
%
% Output:
% str       Datestring rounded to two decimal places
%
%
% Ex:
%     ROUNDMSEC('2018-07-06T01:49:30.600')
%     ROUNDMSEC('2018-07-06T01:49:30.601')
%     ROUNDMSEC('2018-07-06T01:49:30.602')
%     ROUNDMSEC('2018-07-06T01:49:30.603')
%     ROUNDMSEC('2018-07-06T01:49:30.604')
%     ROUNDMSEC('2018-07-06T01:49:30.605')
%     ROUNDMSEC('2018-07-06T01:49:30.606')
%     ROUNDMSEC('2018-07-06T01:49:30.607')
%     ROUNDMSEC('2018-07-06T01:49:30.608')
%     ROUNDMSEC('2018-07-06T01:49:30.609')
%     ROUNDMSEC('2018-07-06T01:49:30.610')
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 12-Nov-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Sanity
if ~strcmp(str(end-3), '.')
    error('String must have three decimal places')
end

% Round milli to centiseconds, chop off last three chars, and append rounded two-chars.
msec = str2num(str(end-3:end));
csec = round(msec, 2);
str(end-3:end) = [];
str = sprintf('%s%.2f', str, csec);
