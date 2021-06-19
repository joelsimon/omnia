function MERMAID = read_simon2021gji_supplement_events(filename)
% MERMAID = READ_SIMON2021GJI_SUPPLEMENT_EVENTS(filename)
%
% Reads the supplementary data text file of MERMAID events,
% simon2021gji_supplement_events.txt, written by
% ???
%
% Input:
% filename       Filename
% (def: $GJI/supplement/data/textfiles/simon2021gji_supplement_events.txt)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('filename', fullfile(getenv('GJI21'), 'supplement', 'data', 'textfiles', ...
                            'simon2021gji_supplement_events.txt'))

sac_fmt = '%44s        ';

evtime_fmt = '%22s        ';
evlo_fmt = '%9.4f        ';
evla_fmt = '%8.4f        ';
magval_fmt = '%3.1f          ';
magtype_fmt = '%3s        ';
evdp_fmt = '%6f        ';

sttime_fmt = '%22s        ';
stlo_fmt = evlo_fmt;
stla_fmt = evla_fmt;
stdp_fmt = '%5f        ';
ocdp_fmt = stdp_fmt;

gcarc_1D_fmt = '%8.4f        ';

contrib_eventid_fmt = '%10s        ';
iris_eventid_fmt = '%8s';

fmt = [sac_fmt ...
       ... %
       evtime_fmt ...
       evlo_fmt ...
       evla_fmt ...
       magval_fmt ...
       magtype_fmt ...
       evdp_fmt ...
       .... %
       sttime_fmt ...
       stlo_fmt ...
       stla_fmt ...
       stdp_fmt ...
       ocdp_fmt ...
       ... %
       gcarc_1D_fmt ...
       ...
       contrib_eventid_fmt ...
       iris_eventid_fmt ...
       '\n'];

% Read.
fid = fopen(filename, 'r');
C = textscan(fid, fmt,  'HeaderLines', 2);

% Parse.
MERMAID.filename  = C{1};
MERMAID.event_time = C{2};
MERMAID.evlo = C{3};
MERMAID.evla = C{4};
MERMAID.mag_val = C{5};
MERMAID.mag_type = C{6};
MERMAID.evdp = C{7};
MERMAID.seismogram_time = C{8};
MERMAID.stlo = C{9};
MERMAID.stla = C{10};
MERMAID.stdp = C{11};
MERMAID.ocdp = C{12};
MERMAID.gcarc_1D = C{13};
MERMAID.NEIC_ID = C{14};
MERMAID.IRIS_ID = C{15};
