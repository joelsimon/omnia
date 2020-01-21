function [sta, lat, lon, sps] = parsecpptstations(txtfile)
% [sta, lat, lon, sps] = PARSECPPTSTATIONS(txtfile)
%
% Parses the textfile 'cpptstations.txt'.
%
% Input:
% txtfile    Textfile of station names to parse,
%                from Hyvernaud Olivier at CPPT
%                def($MERMAID/events/cpptstations/cpptstations.txt)
%
% Output:
% sta       Station abbreviation (char)
% lat       Station latitude in decimal degrees (double)
% lon       Station longitude in decimal degrees (double)
% sps       Station sampling rate, in samples per second (uit)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Jan-2020, Version 2017b on GLNXA64

defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'cpptstations', 'cpptstations.txt'))

fid = fopen(txtfile, 'r');
fmt = '%4s %12.8f %12.7f %3u';
l = textscan(fid, fmt);

sta = l{1};
lat = l{2};
lon = l{3};
sps = l{4};
