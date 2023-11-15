function countsac(procdir)
% COUNTSAC(procdir)
%
% Print $MERMAID .sac file dates and counts.
%
% Input:
% procdir      Processed directory (def: $MERMAID/processed/)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Nov-2023, Version 9.3.0.713579 (R2017b) on GLNXA64

clc
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))

% Find all folders matching, e.g., "452.020-P-06" or "452.120-S-0094"
D = skipdotdir(dir(fullfile(procdir)));
proc_dirs_regexp = regexp(fullfiledir(D), '.*[0-9]-[A-Z]-[0-9].*');
sac_dirs_idx = find(~cellfun(@isempty, proc_dirs_regexp));
sac_dirs = fullfiledir(D(sac_dirs_idx));

tot_sac = 0;
tot_det = 0;
tot_req = 0;
fprintf('                   ALL      DET      LAST_DET     REQ       LAST_REQ\n')
for i = 1:length(sac_dirs);
    sac = globglob(sac_dirs{i}, '**/*.sac');
    [~, det_sac] = cellstrfind(sac, '.DET.');
    [~, req_sac] = cellstrfind(sac, '.REQ.');

    len_sac = length(sac);
    len_det = length(det_sac);
    len_req = length(req_sac);

    if len_det + len_req ~= len_sac
        error('SAC lists don''t sum as expected')

    end

    if ~isempty(det_sac)
        last_det = datestr(fx(sort(mersac2date(det_sac)), 'end'));
        last_det = last_det(1:11);

    else
        last_det = NaT;

    end

    if ~isempty(req_sac)
        last_req = datestr(fx(sort(mersac2date(req_sac)), 'end'));
        last_req = last_req(1:11);

    else
        last_req = NaT;

    end

    fprintf('%14s : %5i    %5i   %11s   %5i    %11s\n', ...
           D(i).name, len_sac, len_det, last_det, len_req, last_req)

    tot_sac = tot_sac + len_sac;
    tot_det = tot_det + len_det;
    tot_req = tot_req + len_req;

end

fprintf('____________________________________________________________________\n')
fprintf('TOTAL :          %5i    %5i                 %5i\n', tot_sac, tot_det, tot_req)
