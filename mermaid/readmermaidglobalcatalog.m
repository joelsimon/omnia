function [eqtime, eqlat, eqlon, eqdepth, eqmag, eqid, mertot, mernum] ...
    = readmermaidglobalcatalog(mercatfile, nfloats)
% [eqtime, eqlat, eqlon, eqdepth, eqmag, eqid, mertot, mernum] ...
%     = READMERMAIDGLOBALCATALOG(mercatfile, nfloats)
%
% READMERMAIDGLOBALCATALOG reads a sing textfile output by
% writemermaidglobalcatalog.m
%
% Input:
% mercatfile  Name of textfile to read
%                (def: $MERMAID/events/reviewed/identified/txt/M6_DET.txt)
% nfloats     Number of floats to consider (def: 16), which
%                 controls the field width of the last column
%
% Output:
% eqtime     Event rupture time in FDSN format (e.g. '2019-09-29T15:57:53.229')
% eqlat      Event latitude [decimal degrees]
% eqlon      Event longitude [decimal degrees]
% eqdepth    Event depth [km]
% eqmag      Event magnitude (IRIS preferred)
% eqid       IRIS event public ID
% mertot     Total number of MERMAIDs reporting positive ID of event
% mernum     Specific float numbers reporting positive ID of event
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Oct-2019, Version 2017b on GLNXA64

% Default.
defval('mercatfile', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                              'identified', 'txt', 'M6_DET.txt'));
defval('nfloats', 16)

% Max length of comma-separated float list, where the float numbers
% are two digits long.
length_float_num_column = (nfloats * 3) - 1;

% Format, based on max length just determined.
fmt = ['%23s    '  , ...
       '%7.3f    ' , ...
       '%8.3f    ' , ...
       '%6.2f    ' , ...
       '%4.1f    ' , ...
       '%8s    '   , ...
       '%2u    '   , ...
       ['%' sprintf('%is', length_float_num_column) '\n']];

% Read it. Parse it.
fid = fopen(mercatfile, 'r');
l = textscan(fid, fmt);
eqtime = l{1};
eqlat = l{2};
eqlon = l{3};
eqdepth = l{4};
eqmag = l{5};
eqid = l{6};
mertot = l{7};
mernum = cellfun(@(xx) str2num(xx), l{8}, 'UniformOutput', false);
