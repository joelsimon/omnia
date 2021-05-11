function [id, sac] = simon2021_seismograms
% [id, sac] = SIMON2021_SEISMOGRAMS
%
% Returns the 6 event IDs (in a cell ordered based on Figure number, e.g.,
% which includes missing values for figures without seismograms), and a
% similarly-indexed cell array of SAC file names plotted in SRL
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Apr-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Define paths.
merdir = getenv('MERMAID');
evtdir = fullfile(merdir, 'events');
sacdir = fullfile(merdir, 'processed');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(evtdir)
system('git checkout GJI21');
cd(sacdir)
system('git checkout GJI21');
cd(startdir)

% Figure 1: Maps
id{1} = {};
sac{1} = {};

% Figure 2: S wave
id{2} = {'10953779'};
sac{2} = {'20180930T105247.08_5BB0F7A4.MER.DET.WLT5.sac', ...
          '20180930T105316.09_5BB96E33.MER.DET.WLT5.sac', ...
          '20180930T105338.10_5BB96C72.MER.DET.WLT5.sac'};

% Figure 3: Surface wave
id{3} = {'11154761'};
sac{3} = {'20191206T130408.08_5DF32AF0.MER.DET.WLT5.sac'};

% Figure 4: T wave
id{4} = {'11185155'};
sac{4} = {'20200215T093807.08_5E4808BE.MER.DET.WLT5.sac'};

% Figure 5: Diagram
id{5} = {};
sac{5} = {};

% Figure 6: Ray paths
id{6} = {};
sac{6} = {};

% Figure 7: PKIKP wave
id{7} = {'11160212'};
sac{7} = {'20191220T115726.16_5E0574F1.MER.DET.WLT5.sac'};

% Figure 8: PKP record sections
% Only the MERMAID seismograms; there are also nearby island seismograms
id{8} = {'10964158'};
sac{8} = {'20181025T231300.19_5BD80EDE.MER.DET.WLT5.sac', ...
          '20181025T231318.08_5BD3ADDA.MER.DET.WLT5.sac', ...
          '20181025T231318.13_5BD80CFE.MER.DET.WLT5.sac', ...
          '20181025T231330.09_5BD6FE4A.MER.DET.WLT5.sac'};

% Figure 9: PKP "model residuals" -- the ones that made the cut
id{9} = {'10964158', ...
         '10974404', ...
         '11150631', ...
         '11160212'};
sac{9} = {'20191220T115726.17_5DFD08D3.MER.DET.WLT5.sac', ...
          '20181025T231300.19_5BD80EDE.MER.DET.WLT5.sac', ...
          '20191126T031228.08_5DDCE5B6.MER.DET.WLT5.sac', ...
          '20191220T115739.24_5DFD07A6.MER.DET.WLT5.sac', ...
          '20191126T031232.09_5DDCE62E.MER.DET.WLT5.sac', ...
          '20181025T231318.13_5BD80CFE.MER.DET.WLT5.sac', ...
          '20191126T031240.11_5DDCE65A.MER.DET.WLT5.sac', ...
          '20181025T231318.08_5BD3ADDA.MER.DET.WLT5.sac', ...
          '20181025T231330.09_5BD6FE4A.MER.DET.WLT5.sac', ...
          '20181125T165601.12_5BFB20F4.MER.DET.WLT5.sac'};

% Figure 10: Unidentified local events -- no associated event ID
id{10} = {};
sac{10} = {'20190705T091235.08_5D1F627A.MER.DET.WLT5.sac'};
