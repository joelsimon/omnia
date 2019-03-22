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
diro = getenv('MERAZUR');

for i = 1:length(s)
    [EQ, ~, err] = rematch_merazur(s{i}, redo, diro);
    close all

end

