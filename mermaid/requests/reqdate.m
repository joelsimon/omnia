function sac_datestr = reqdate(sac_date)
% sac_datestr = REQDATE(sac_date)
%
% Converts UTC datetime to datestr formatted for MERMAID request,
% e.g., ISO 8601 format except that ":" is replaced with "_".
%
% Input:
% sac_date      Datetime in UTC of start date of MERMAID request
%
% Output:
% sac_datestr   Datestr of 'sac_date', formatted for MERMAID request
%
% Ex: (format date string for UTC time of first sample)
%    [~, header] = readsac('20180629T170731.06_5B3F1904.MER.DET.WLT5.sac');
%    sac_date = seistime(header); sac_date = sac_date.B;
%    sac_datestr = REQDATE(sac_date)
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Sanity.
if ~isa(sac_date, 'datetime')
    error('''sac_date'' must a datetime object')

end
if ~strcmp(sac_date.TimeZone, 'UTC')
    error('''sac_date'' .TimeZone must be UTC')

end

% Main.
fmt = 'yyyy-mm-ddTHH_MM_SS';
sac_datestr = datestr(sac_date, fmt);
