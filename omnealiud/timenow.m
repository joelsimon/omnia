function time = timenow(precision, noz)
% time = TIMENOW(precision, noz)
%
% Returns iso8601 UTC time right now.
%
% Input:
% precision    1: seconds, e.g., '2007-04-05T14:30Z' (def)
%              2: milliseconds, e.g., '2007-04-05T01:14:30.123Z'
%              3: microseconds, e.g., '2007-04-05T01:14:30.123456Z'
%              4: centisecond, e.g., '2007-04-05T01:14:30.12Z'
% noz          true if no "Z", e.g., '2007-04-05T14:30' (def: false)
%
% Output:
% time         iso8061 string or cell array, e.g. '2007-04-05T01:14:30Z'
%
% Ex:
%    TIMENOW
%    TIMENOW(1, true)
%    TIMENOW(1, false)
%    TIMENOW(2, true)
%    TIMENOW(2, false)
%    TIMENOW(3, true)
%    TIMENOW(3, false)
%    TIMENOW(4, true)
%    TIMENOW(4, false)
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 07-Nov-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

defval('precision', 1)
defval('noz', false)
time = iso8601date2str(datetime('now', 'TimeZone', 'UTC'), precision, noz);
