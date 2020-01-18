function writechangepointall
% Function to run writechangepoint.m on all identified SAC files
% assuming JDS' system configuration.
%
% Compute M1 error estimation for every SAC file using 1000
% iterations.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Jan-2020, Version 2017b on GLNXA64

diro = fullfile(getenv('MERMAID'), 'events', 'changepoints');
s = fullsac;
%pool = gcp;
%parfor i = 1:length(s)
for i = 1:length(s)
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
        writechangepoint(sans_sac, diro, 'time', x, n, h.DELTA, h.B, 1, cpinputs, 1);

    end        
end
%delete(pool)
