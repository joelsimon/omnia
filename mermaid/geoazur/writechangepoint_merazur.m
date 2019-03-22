% Script to run writechangepoint.m on all identified GeoAzur SAC files
% assuming JDS' system configuration.
%
% Compute M1 error estimation for every SAC file using 1000
% iterations.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-Mar-2019, Version 2017b

% Default directories.
sac_diro = getenv('MERAZUR');
cp_diro = fullfile(getenv('MERMAID'), 'events', 'geoazur', 'changepoints');

% Nab all the SAC files.
s = mermaid_sacf('id');

for i = 1   
    % Read data.
    [x, h] = readsac(s{i});

    % Determine number of wavelet scales of decomposition based on
    % sampling rate.
    if efes(h) == 20
        n = 5;
        
    else
        n = 3;
        
    end

    % Remove .sac filename extension.
    sans_sac = strrep(strippath(s{i}), '.sac', '');

    % Compute changepoint and save the structure.
    writechangepoint(sans_sac, cp_diro, false, 'time', x, n, h.DELTA, h.B, 1, cpinputs, 1);

end
    
    
    
    