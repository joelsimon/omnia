% Script to review all unreviewed $MERMAID events using reviewevt.m,
% assuming same system configuration as JDS.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 10-Mar-2019, Version 2017b

close all
clear all

s = fullsac;
for i = 1:length(s)
    i
    reviewevt(s{i}, false);
    clc

end
evt2txt;
fprintf('All done.\n')
