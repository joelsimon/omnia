function tstr = pdetime2str(tdate)
% tstr = PDETIME2STR(tdate)
% 
% Opposite of pdetime2date.m.  Takes PDE event in datetime format and
% returns it in datestr format.  Returns in exactly same format of PDE
% catalog, meaning it goes to two-digit millisecond precision (SAC
% file headers go to 3 digit millisecond precision).
%
% Input:
% tdate         Time in datetime format
%
% Output: 
% tstr          Time in datestr formatted like PDE catalog record line
%
% See also: seistime.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 24-Nov-2018, Version 2017b

% PDE catalog format.
strfmt = 'yyyy/mm/dd HH:MM:SS.FFF';
tstr = datestr(tdate,strfmt);

% Get rid of 3rd digit of millisecond precision
tstr = tstr(1:end-1);
