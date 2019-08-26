function tdate = irisstr2date(tstr, precision)
% tdate = IRISSTR2DATE(tstr, precision)
%
% IRISSTR2DATE converts a character array formatted such that it is a
% valid input to irisFetch to a datetime.
%
% Input:
% tstr       Datestr formatted for irisFetch
% precision  Specify 1 or 2 for datetime format
%            1:'uuuu-MM-dd HH:mm:ss.SSS'
%            2:'uuuu-MM-dd HH:mm:ss'
%
% Output:
% tdate      Datetime 
%
% See also: irisdate2str, fdsndate2str.m, fdsnstr2date.m
%
% Ex:
%    tstr1 ='2018-09-16 21:11:48.820';
%    tstr2 ='2018-09-16 21:11:48';
%    tdate1 = IRISSTR2DATE(tstr1, 1)
%    second(tdate1)
%    tdate2 = IRISSTR2DATE(tstr2, 2)
%    second(tdate2)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-Aug-2019, Version 2017b

% Default.
defval('precision', 1)

% Switch format.
switch precision
  case 1
    fmt = 'uuuu-MM-dd HH:mm:ss.SSS';
    
  case 2
    fmt = 'uuuu-MM-dd HH:mm:ss';
    
  otherwise
    error('Please specify either 1 or 2 for the second input')
    
end

% https://www.mathworks.com/help/matlab/ref/datetime.html?searchHighlight=datetime&s_tid=doc_srchtitle#buhzxmk-1-Format
tdate = datetime(tstr, 'InputFormat', fmt, 'TimeZone', 'UTC');
