% Script to run writechangepoint.m on all identified SAC files
% assuming JDS' system configuration.
%
% Compute M1 error estimation for every SAC file using 1000
% iterations.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Mar-2019, Version 2017b

diro = fullfile(getenv('MERMAID'), 'events', 'changepoints');
s = fullsac;
parfor i = 1:length(s)
    CP = getcp(s{i}, diro);
    if isempty(CP)
        sans_sac = strrep(strippath(s{i}), '.sac', '');
        [x, h] = readsac(s{i});
        writechangepoint(sans_sac, diro, 'time', x, 5, h.DELTA, h.B, 1, cpinputs, 1);

    end        
end
    
    
    
    