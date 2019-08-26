function tstr = irisdate2str(tdate, precision)
% tstr = IRISDATE2STR(tdate, precision)
%
% IRISDATE2STR converts a datetime to a character array formatted such
% that it is a valid input to irisFetch.
%
% Input:
% tdate      Datetime 
% precision  Specify 1 or 2 for datestr format
%            1:'yyyy-mm-dd HH:MM:SS.FFF'
%            2:'yyyy-mm-dd HH:MM:SS'
%
% Output:
% tstr      Datestr formatted for irisFetch
%
% See also: irisstr2date, fdsndate2str.m, fdsnstr2date.m
%
% Ex:
%    tdate = datetime('now');
%    IRISDATE2STR(tdate, 1)
%    IRISDATE2STR(tdate, 2)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 13-Jun-2019, Version 2017b

% Default.
defval('precision', 1)

% Switch format.
switch precision
  case 1
    fmt = 'yyyy-mm-dd HH:MM:SS.FFF';
    
  case 2
    fmt = 'yyyy-mm-dd HH:MM:SS';
    
  otherwise
    error('Please specify either 1 or 2 for the second input')
    
end

% Do it.
tstr = datestr(tdate, fmt);
