function tdate = mseed2sac2date(sac)
% tdate = MSEED2SAC2DATE(sac)
%
% Returns the datetime (whole-second precision) of a SAC file converted with mseed2sac.
%
% Input:
% sac        MERMAID SAC filename (accepts cell arrays)
%
% Output:
% tdate      Datetime array of UTC starttimes
%
% Ex:
%    sac = 'MH.P0008..BDH.D.2018.220.014200.SAC'
%    tdate = MSEED2SAC2DATE(sac)
%
% See also: seistime.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

sac = strippath(sac);
if iscell(sac)
    C = cellfun(@(xx) strsplit(xx, '.'), sac, 'UniformOutput', false);
    tstr = cellfun(@(xx) [xx{5:end-1}], C, 'UniformOutput', false);

else
    C = strsplit(sac, '.');
    tstr = [C{5:end-1}];

end

fmt = 'uuuuDDDHHmmss';
tdate = datetime(tstr, 'InputFormat', fmt, 'TimeZone', 'UTC');
