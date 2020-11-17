function tdate = mersac2date(sac)
% tdate = MERSAC2DATE(sac)
%
% Returns the UTC time of the first sample of a gen 3+ MERMAID
% (manufactured by Osean) SAC file written by automaid.
%
% MERSAC2DATE simply parses the SAC filename and returns precision in
% seconds. For milliseconds precision see seistime.m.
%
% Input:
% sac        MERMAID SAC filename (accepts cell arrays)
%
% Output:
% tdate      Datetime corresponding UTC time
%                of first sample of seismogram
%
% Ex:
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    tdate = MERSAC2DATE(sac)
%
% See also: seistime.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Strip date from first 15 chars of filename.
if iscell(sac)
    tstr = cellfun(@(xx) xx(1:15), sac, 'UniformOutput', false);

else
    tstr = sac(1:15);

end

% Create datetime array.
fmt = 'uuuuMMdd''T''HHmmss';
tdate = datetime(tstr, 'InputFormat', fmt, 'TimeZone', 'UTC');
