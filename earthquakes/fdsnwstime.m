function tstr = fdsnwstime(tdate)
% tstr = FDSNWSTIME(tdate)
%
% FDSNWSTIME converts a datetime to character array formatted to the
% International Federation of Digital Seismograph Networks (FDSN) Web
% Service Specifications Version 1.1. See
% http://www.fdsn.org/webservices/FDSN-WS-Specifications-1.1.pdf
% pg. 6, 'Time parameter values'.
%
% Ignores any fractional seconds beyond 3 digits (milliseconds).
%
% Ex: datetime and datestr of reported event time
%    [~, h] = readsac('m35.20140915T080858.sac');
%    [~, ~, ~, ~, tdate] = seistime(h)
%    tstr = FDSNWSTIME(tdate)
%    second(tdate)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Mar-2019, Version 2017b

fmt = 'yyyy-mm-ddTHH:MM:SS.FFF';
tstr = datestr(tdate, fmt);
