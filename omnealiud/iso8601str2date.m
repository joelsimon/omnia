function tdate = iso8601str2date(tstr, precision, noz)
% tdate = ISO8601STR2DATE(tstr, precision, noz)
%
% Returns datetime array given input in iso8601 <date>T<time>Z format (UTC).
%
% Input:
% tstr         iso8061 string or cell array, e.g. '2007-04-05T01:14:30Z'
% precision    1: seconds, e.g., '2007-04-05T14:30Z' (def)
%              2: milliseconds, e.g., '2007-04-05T01:14:30.123Z'
%              3: microseconds, e.g., '2007-04-05T01:14:30.123456Z'
%              4: centisecond, e.g., '2007-04-05T01:14:30.12Z'
% noz          true if no "Z", e.g., '2007-04-05T14:30' (def: false)
%
% Output:
% tdate        Datetime array
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('precision', 1)
defval('noz', false)

% Switch format specification
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

% Chop off trailing "Z" from formatspec, if not supplied with input datestr.
if noz
    Format = strrep(Format, '''Z''', '');

end

% Convert from string to datetime.
tdate = datetime(tstr, 'Format', Format, 'TimeZone', 'UTC');
