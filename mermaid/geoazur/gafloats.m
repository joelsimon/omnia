function [floats, startdate, enddate] = gafloats(merazur)
% [floats, startdate, enddate] = GAFLOATS(merazur)
%
% GAFLOATS returns the float numbers and dates of the first/last
% seismograms contained in (recursively) in the path 'merazur'.
%
% Input: 
% merazur       A path to GeoAzur MERMAID data (def: $MERAZUR)
%
% Output:
% floats        Array of 2-digit float numbers
% start/enddate Start and end date of first/last seismogram
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Feb-2019, Version 2017b

% Default.
defval('merazur', getenv('MERAZUR'))

% Fetch all data and parse relevant info from filename.
s = mermaid_sacf('all', merazur);
snum = zeros(length(s), 1);
sdate = celldeal(s, NaN);
for i = 1:length(s)
    s{i} = strippath(s{i});
    snum(i) = str2double(s{i}(2:3));
    sdate{i} = s{i}(5:19);

end
floats = unique(snum);
sdate = sort(sdate);
startdate = sdate(1);
enddate = sdate(end);

