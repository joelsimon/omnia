% Script to match all unmatched $MERMAID SAC files to the IRIS
% database using cpsac2evt.m and its defaults, assuming same system
% configuration as JDS.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Mar-2019, Version 2017b

close all
clear all

s = fullsac;
for i = 1:length(s)
    [x, h] = readsac(s{i});
    switch efes(h)
      case 20
        n = 5;
        
      case 5
        n = 3;
        
      otherwise
        error('Unrecognized sampling frequency')
        
    end
    cpsac2evt(s{i}, false, [], n);
    close all
    clc

end

fprintf('All done.\n')
