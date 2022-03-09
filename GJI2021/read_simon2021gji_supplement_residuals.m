function MERMAID = read_simon2021gji_supplement_residuals(filename)
% MERMAID = READ_SIMON2021GJI_SUPPLEMENT_RESIDUALS(filename)
%
% Reads the supplementary data text file of MERMAID residuals,
% simon2021_supplement_residuals.txt, written by
% write_simon2021_supplement_residuals.txt
%
% Note that arrival times are given as offsets in seconds from the start of the
% seismogram, i.e., assuming the first sample is tacked at 0 s (as opposed to it
% being assigned some offset, such as field "B" from the SAC header).
%
% Input:
% filename       Filename
%                (def: $GJI21_CODE/data/supplement/simon2021gji_supplement_residuals.txt)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('filename', fullfile(getenv('GJI21_CODE'), 'data', 'supplement', ...
                            'simon2021gji_supplement_residuals.txt'))

% Specify formats.
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

gcarc_1D_fmt = '%7.4f        ';
gcarc_1Dadj_diff_fmt = '%6f        ';
gcarc_1Dadj_fmt = gcarc_1D_fmt;
gcarc_3D_diff_fmt = '%7.4f        ';
gcarc_3D_fmt = gcarc_1D_fmt;

exp_travtime_1D_fmt = '%7.2f        ';
exp_travtime_1Dadj_diff_fmt = '%5.2f        ';
exp_travtime_1Dadj_fmt = exp_travtime_1D_fmt;
tadj_1D_fmt = exp_travtime_1Dadj_diff_fmt;
exp_travtime_3D_diff_fmt = exp_travtime_1Dadj_diff_fmt;
exp_travtime_3D_fmt = exp_travtime_1D_fmt;
tadj_3D_fmt = exp_travtime_3D_diff_fmt;

obs_travtime_fmt = '%6.2f        ';
obs_arvltime_fmt = obs_travtime_fmt;
SNR_fmt= '%6f        ';
twosd_fmt = obs_arvltime_fmt;

exp_arvltime_1D_fmt = '%6.2f        ';
exp_arvltime_1Dadj_diff_fmt = '%5.2f        ';
exp_arvltime_1Dadj_fmt = exp_arvltime_1D_fmt;
exp_arvltime_3D_fmt = exp_arvltime_1D_fmt;

tres_1D_fmt = '%6.2f        ';
tres_1Dadj_diff_fmt = '%5.2f        ';
tres_1Dadj_fmt = tres_1D_fmt;
tres_3D_fmt = tres_1D_fmt;

max_counts_fmt = '%9f        ';
max_delay_fmt = '%4.2f        ';

contrib_eventid_fmt = '%10s        ';
iris_eventid_fmt = '%8s';

fmt = [sac_fmt ...                      % 1
       ... %
       evtime_fmt ...
       evlo_fmt ...
       evla_fmt ...
       magval_fmt ...                   % 5
       magtype_fmt ...
       evdp_fmt ...
       .... %
       sttime_fmt ...
       stlo_fmt ...
       stla_fmt ...                     % 10
       stdp_fmt ...
       ocdp_fmt ...
       ... %
       gcarc_1D_fmt ...
       gcarc_1Dadj_diff_fmt ...
       gcarc_1Dadj_fmt ...              % 15
       gcarc_3D_diff_fmt ...
       gcarc_3D_fmt ...
       ...
       obs_travtime_fmt ...
       obs_arvltime_fmt ...
       ... %
       exp_travtime_1D_fmt ...          % 20
       exp_arvltime_1D_fmt ...
       tres_1D_fmt ...
       ... %
       tadj_1D_fmt ....
       exp_travtime_1Dadj_fmt ...
       exp_arvltime_1Dadj_fmt ...   % 25
       tres_1Dadj_fmt ...
       ... %
       tadj_3D_fmt ...
       exp_travtime_3D_fmt ...
       exp_arvltime_3D_fmt ...
       tres_3D_fmt ...                  % 30
       ... %
       twosd_fmt ...
       SNR_fmt ...
       max_counts_fmt ...
       max_delay_fmt ...
       ...
       contrib_eventid_fmt ...          % 35
       iris_eventid_fmt ...             % 36
       '\n'];

% Read.
fid = fopen(filename, 'r');
C = textscan(fid, fmt,  'HeaderLines', 2);

% Parse.
MERMAID.filename  = C{1};
MERMAID.event_time = C{2};
MERMAID.evlo = C{3}; % -180:180 longitude
MERMAID.evlo_360 = MERMAID.evlo;
MERMAID.evlo_360(MERMAID.evlo_360<0) = MERMAID.evlo(MERMAID.evlo_360<0) + 360; % 0:360 longitude
MERMAID.evla = C{4};
MERMAID.mag_val = C{5};
MERMAID.mag_type = C{6};
MERMAID.evdp = C{7};
MERMAID.seismogram_time = C{8};
MERMAID.stlo = C{9}; % -180:180 longitude
MERMAID.stlo_360 = MERMAID.stlo;
MERMAID.stlo_360(MERMAID.stlo_360<0) = MERMAID.stlo(MERMAID.stlo_360<0) + 360; % 0:360 longitude
MERMAID.stla = C{10};
MERMAID.stdp = C{11};
MERMAID.ocpd = C{12};
MERMAID.gcarc_1D = C{13};
MERMAID.gcarc_1Dstar_adj = C{14};
MERMAID.gcarc_1Dstar = C{15};
MERMAID.gcarc_3D_adj = C{16};
MERMAID.gcarc_3D = C{17};
MERMAID.obs_travtime = C{18};
MERMAID.obs_arvltime = C{19};
MERMAID.travtime_1D = C{20};
MERMAID.arvltime_1D = C{21};
MERMAID.tres_1D = C{22};
MERMAID.travtime_1Dstar_adj = C{23};
MERMAID.travtime_1Dstar = C{24};
MERMAID.arvltime_1Dstar = C{25};
MERMAID.tres_1Dstar = C{26};
MERMAID.travtime_3D_adj = C{27};
MERMAID.travtime_3D = C{28};
MERMAID.arvltime_3D = C{29};
MERMAID.tres_3D = C{30};
MERMAID.twosd = C{31};
MERMAID.SNR = C{32};
MERMAID.max_counts = C{33};
MERMAID.max_delay = C{34};
MERMAID.NEIC_ID = C{35};
MERMAID.IRIS_ID = C{36};
