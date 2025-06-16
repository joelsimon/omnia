function tstr = iso8601date2str(tdate, precision, noz)
% tstr = ISO8601DATE2STR(tdate, precision, noz)
%
% Returns string in (pusdeo) iso8601 <date>T<time>Z format (UTC) given datetime.
%
% Input:
% tdate        Datetime array
% precision    1: seconds, e.g., '2007-04-05T14:30Z' (def)
%              2: milliseconds, e.g., '2007-04-05T01:14:30.123Z'
%              3: microseconds, e.g., '2007-04-05T01:14:30.123456Z'
%              4: centisecond, e.g., '2007-04-05T01:14:30.12Z'
% noz          true if no "Z", e.g., '2007-04-05T14:30' (def: false)
%
% Output:
% tstr         iso8061 string or cell array, e.g. '2007-04-05T01:14:30Z'
%
% Ex:
%    tdate = datetime('now', 'TimeZone', 'UTC');
%    ISO8601DATE2STR(tdate, 1, true)
%    ISO8601DATE2STR(tdate, 1, false)
%    ISO8601DATE2STR(tdate, 2, true)
%    ISO8601DATE2STR(tdate, 2, false)
%    ISO8601DATE2STR(tdate, 3, true)
%    ISO8601DATE2STR(tdate, 3, false)
%    ISO8601DATE2STR(tdate, 4, true)
%    ISO8601DATE2STR(tdate, 4, false)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-May-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Defaults.
defval('precision', 1)
defval('noz', false)

% Sanity.
if ~strcmp(tdate.TimeZone, 'UTC')
    error('tdate.TimeZone must be ''UTC''')

end

% Switch format specification (using datetime format, not datestr).
switch precision
  case 1
    Format = 'uuuu-MM-dd''T''HH:mm:ss''Z''';

  case 2
    Format = 'uuuu-MM-dd''T''HH:mm:ss.SSS''Z''';

  case 3
    Format = 'uuuu-MM-dd''T''HH:mm:ss.SSSSSS''Z''';

  case 4
    Format = 'uuuu-MM-dd''T''HH:mm:ss.SS''Z''';

  otherwise
    error('Specify one of [1:4] (inclusive) for input ''precision''')

end

% Maybe don't include trailing "Z".
if noz
    Format(end) = [];

end

% Convert from datetime to string.  Use (new) `string` and not (depreciated)
% `datestr` because the latter doesn't natively allow millisecond precision.
tstr = string(tdate, Format);
