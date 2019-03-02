function pdedate = pdetime2date(tstr)
% pdedate = PDETIME2DATE(tstr)
%
% Opposite of pdetime2str.m. Takes PDE event in datestr format
% ('uuuu/MM/dd HH:mm:ss.SS') and returns it in datetime format.
%
% Input:
% tstr            Time in PDE/ISC datestr format
%
% Output:
% pdedate         Time in datetime format
%
% See also: seistime.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Mar-2018, Version 2017b

pdedate = datetime(tstr,'InputFormat',['uuuu/MM/dd HH:mm:' ...
                    'ss.SS'],'TimeZone','UTC');

