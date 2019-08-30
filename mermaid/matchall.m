function matchall
% Matches all unmatched $MERMAID SAC files to the IRIS
% database using cpsac2evt.m and its defaults, assuming same system
% configuration as JDS.
%
% Also writes .cp files with M1 uncertainty estimates.
%
% A list of any files which are unsuccessfully matched using
% cpsac2evt.m are saved as 'matchall_fail.txt' $MERMAID/events (or
% empty if all successfully matched).
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Aug-2019, Version 2017b

% Find only those SAC files which have not been preliminary matched.
allsac = fullsac;
rawevt = skipdotdir(dir(fullfile(getenv('MERMAID'), 'events', 'raw', 'evt')));
already_matched = strrep({rawevt.name}, '.raw.evt', '.sac'); % Not necessarily reviewed!
allsac_nopath = cellfun(@(xx) strippath(xx), allsac, 'UniformOutput', false);
[~, idx] = setdiff(allsac_nopath, already_matched);

% Loop over the unmatched SAC files.
fail = [];
new = 0;
s = allsac(idx);
fprintf('Searching for unmatched SAC files...\n')
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
    try
        cpsac2evt(s{i}, false, 'time', n);
        new = [new + 1];

    catch
        fail = [fail i];

    end
    close all

end

% Write changepoint (.cp) files.
if new > 0
    fprintf('Writing changepoint files...\n')
    writechangepointall;

end

% Make note of the SAC files that failed to be properly processed by cpsac2evt.m.
if ~isempty(fail)
    failsac = s(fail);
    failsac = cellfun(@(xx) strippath(xx), failsac, 'UniformOutput', ...
                      false)
    warning(['These SAC files were not matched:\n' ...
             repmat('%s\n', 1, length(failsac))], failsac{:})

else
    failsac = {};

end
fid = fopen(fullfile(getenv('MERMAID'), 'events', 'raw', 'matchall_fail.txt'), 'w');
fprintf(fid, '%s\n', failsac{:});
fclose(fid);

fprintf('\n\nAll done.\n')
