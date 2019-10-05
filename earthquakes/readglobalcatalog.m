function [eqtime, eqlat, eqlon, eqdepth, eqmag, eqid] = readglobalcatalog(txtfile)
% [eqtime, eqlat, eqlon, eqdepth, eqmag, eqid] = READGLOBALCATALOG(txtfile)
%
% READGLOBALCATALOG reads the textfiles output by writeglobalcatalog.m
%
% Input:
% txtfile    Name of textfile to read
%                (def: $MERMAID/events/globalcatalog/M5.txt)
% Output:
% eqtime     Event rupture time ['yyyy-mm-dd HH:MM:SS.FFF']
% eqlat      Event latitude [decimal degrees]
% eqlon      Event longitude [decimal degrees]
% eqdepth    Event depth [km]
% eqmag      Event magnitude (IRIS preferred)
% eqid       IRIS event public ID
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Oct-2019, Version 2017b on GLNXA64

% Default.
defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'globalcatalog', 'M5.txt'));

% File format.
fmt = ['%23s    '  , ...
       '%7.3f    ' , ...
       '%8.3f    ' , ...
       '%6.2f    ' , ...
       '%4.1f    ' , ...
       '%8s\n'];

% Read it. Parse it.
fid = fopen(txtfile, 'r');
l = textscan(fid, fmt);
eqtime = l{1};
eqlat = l{2};
eqlon = l{3};
eqdepth = l{4};
eqmag = l{5};
eqid = l{6};
