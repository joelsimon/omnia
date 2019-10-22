function tdate = fdsnstr2date(tstr)
% tdate = FDSNSTR2DATE(tstr)
%
% FDSNSTR2DATE converts a datestr character array, formatted per the
% International Federation of Digital Seismograph Networks (FDSN) Web
% Service Specifications Version 1.1, e.g.
%
%               2019-03-25T14:32:08.191
%
% to a datetime object in the UTC timezone.
%
% See http://www.fdsn.org/webservices/FDSN-WS-Specifications-1.1.pdf
% pg. 6, 'Time parameter values'.
%
% Ignores any fractional seconds beyond 3 digits (milliseconds).
%
% Input:
% tstr        Time string formatted per FDSN specification.
%
% Output:
% tdate       Datetime object
%
% Ex: (datetime and datestr of reported event time)
%    [~, h] = readsac('m35.20140915T080858.sac');
%    [~, ~, ~, ~, tdate1] = seistime(h)
%    tstr = fdsndate2str(tdate1)
%    tdate2 = FDSNSTR2DATE(tstr)
%    second(tdate2)
%
% See also: fdsndate2str
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 08-Oct-2019, Version 2017b on GLNXA64

%% Recursive.

if iscell(tstr)
    tdate = NaT(size(tstr), 'TimeZone', 'UTC');
    for i = 1:length(tstr)

        %% Recursive.

        tdate(i) = fdsnstr2date(tstr{i});

    end
    return

end

% Remove the "T" at the 11th index.
tstr(11) = [];

% https://www.mathworks.com/help/matlab/ref/datetime.html?searchHighlight=datetime&s_tid=doc_srchtitle#buhzxmk-1-Format
fmt = 'uuuu-MM-ddHH:mm:ss.SSS';
tdate = datetime(tstr, 'InputFormat', fmt, 'TimeZone', 'UTC');
