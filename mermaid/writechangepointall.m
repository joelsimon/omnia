function writechangepointall
% WRITECHANGEPOINTALL
%
% Function to run writechangepoint.m on all identified SAC files assuming JDS'
% system configuration.
%
% Compute M1 error estimation for every SAC file using 1000 iterations.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Apr-2020, Version 9.3.0.713579 (R2017b) on GLNXA64

fprintf('Searching for SAC files without corresponding changepoint files...\n')
diro = fullfile(getenv('MERMAID'), 'events', 'changepoints');
s = fullsac;
pool = gcp;
parfor i = 1:length(s)
    CP = getcp(s{i}, diro);
    if isempty(CP)
        sans_sac = strrep(strippath(s{i}), '.sac', '');
        [x, h] = readsac(s{i});

        % Determine number of wavelet scales based on SAC filename.
        if ~isempty(strfind(sans_sac, 'RAW'));
            n = 6

        else
            wlt_idx = strfind(sans_sac, 'WLT');
            n = sans_sac(wlt_idx+3:end);
            n = str2double(n);

        end
        fprintf('Writing changepoint file for %s....\n', strippath(s{i}))
        writechangepoint(sans_sac, diro, 'time', x, n, h.DELTA, h.B, 1, cpinputs, 1);
        fprintf('Done.\n\n', strippath(s{i}))

    end
end
delete(pool)
fprintf('Done writing changepoint files\n')