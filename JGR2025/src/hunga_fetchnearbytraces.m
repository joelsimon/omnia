function hunga_fetchnearbytraces(redo)
% HUNGA_FETCHNEARBYTRACES(redo)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Sep-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('redo', false)
id = '11516993';
startend = [datetime('2022-01-15') datetime('2022-01-16')];
ph = ['P, S, 4kmps, 3.5kmps, 3kmps, 2.5kmps, 2kmps, 1.5kmps, 1kmps'];

fetchnearbytraces(id, redo, [], [], [], [], ph, startend);
