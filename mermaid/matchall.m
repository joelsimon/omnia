% Script to match all unmatched $MERMAID SAC files to the IRIS
% database using cpsac2evt.m and its defaults, assuming same system
% configuration as JDS.
%
% Also writes .cp files with M1 uncertainty estimates.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-May-2019, Version 2017b

clear
close all

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
    % Write raw event (.raw.evt) files).
    cpsac2evt(s{i}, false, 'time', n);
    close all

end

% Open parallel pool for writechangepointall.m if none exists.
pool = gcp;

% Write changepoint (.cp) files.
fprintf('Writing changepoint files...\n')
writechangepointall;
delete(pool)

% Write a list of current SAC files for use in reviewall.m
save(fullfile(getenv('MERMAID'), 'events','sacfiles.mat'), 's')

fprintf('All done.\n')
