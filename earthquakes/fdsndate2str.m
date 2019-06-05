function tstr = fdsndate2str(tdate)
% tstr = FDSNDATE2STR(tdate)
%
% FDSNDATE2STR converts a datetime to a character array formatted to the
% International Federation of Digital Seismograph Networks (FDSN) Web
% Service Specifications Version 1.1,
%
%               2019-03-25T14:32:08.191
% 
% See http://www.fdsn.org/webservices/FDSN-WS-Specifications-1.1.pdf
% pg. 6, 'Time parameter values'.
%
% Ignores any fractional seconds beyond 3 digits (milliseconds).
% 
% Input:
% tdate       Datetime object
% 
% Output:
% tstr        Time string formatted per FDSN specification.
%             
%
% Ex: datetime and datestr of reported event time
%    [~, h] = readsac('m35.20140915T080858.sac');
%    [~, ~, ~, ~, tdate] = seistime(h)
%    tstr = FDSNDATE2STR(tdate)
%    second(tdate)
%
% See also: fdsnstr2date
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Jun-2019, Version 2017b

fmt = 'yyyy-mm-ddTHH:MM:SS.FFF';
tstr = datestr(tdate, fmt);
