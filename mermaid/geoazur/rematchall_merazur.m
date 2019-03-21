% Script to run all GeoAzur seismograms through rematch.m assuming JDS
% default system.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 19-Mar-2019, Version 2017b

close all
clear all

redo = false;
s = mermaid_sacf('id');
defval('ga_diro', getenv('MERAZUR'))
evt_diro = fullfile(getenv('MERMAID'), 'events', 'geoazur');

idx = [];
for i = 1:length(s);
    EQ = rematch_merazur(s{i}, ga_diro, evt_diro, redo);
    close all
    
end
