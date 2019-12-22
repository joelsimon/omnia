function [eqtime, eqlat, eqlon, eqdepth, eqmag, eqid, mertot, mernum, mernumstr] ...
    = readmermaidglobalcatalog(mercatfile, nfloats)
% [eqtime, eqlat, eqlon, eqdepth, eqmag, eqid, mertot, mernum, mernumstr] ...
%     = READMERMAIDGLOBALCATALOG(mercatfile, nfloats)
%
% READMERMAIDGLOBALCATALOG reads a single-magnitude textfile output by
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
% mernum     Specific float numbers reporting positive ID of event (double)
% mernumstr  Specific float numbers reporting positive ID of event (cell of chars)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Dec-2019, Version 2017b on GLNXA64

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
       '%2f    '   , ...
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
mernumstr = l{8};

% Ensure proper sorting.
[~, idx] = sort(eqtime);
eqtime = eqtime(idx);
eqlat = eqlat(idx);
eqlon = eqlon(idx);
eqdepth = eqdepth(idx);
eqmag = eqmag(idx);
eqid = eqid(idx);
mertot = mertot(idx);
mernum = mernum(idx);
mernumstr = mernumstr(idx);
