 function merstr = reqdate(merdate)
% merstr = REQDATE(merdate)
%
% Converts datetime object to datestr formatted for MERMAID request,
% e.g., ISO 8601 format except that ":" is replaced with "_".
%
% Input:
% merdate      Datetime object of start date of MERMAID request
%
% Output:
% merstr       Datestr of merdate, formatted for MERMAID request
%
% Ex: (format date string for UTC time of first sample)
%    [~, header] = readsac('20180629T170731.06_5B3F1904.MER.DET.WLT5.sac');
%    seisdate = seistime(header);
%    merstr = REQDATE(seisdate.B)
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

fmt = 'yyyy-mm-ddTHH_MM_SS';
merstr = datestr(merdate, fmt);
