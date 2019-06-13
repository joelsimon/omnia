% Script to write all EQ and CP structures, and travel-time residuals
% for all GeoAzur identified SAC files to the rematched directory,
% assuming JDS system defaults.
%
% Writes 'compile_merazur.mat', read by fig20.m of simon+2019 (travel
% time residual histograms).
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 15-May-2019, Version 2017b

clear
close all

% Load data. 
defval('sac_diro', getenv('MERAZUR'));
defval('rematch_diro', fullfile(getenv('MERAZUR'), 'rematch'));
defval('redo', false)

% Sort SAC files based on time of first sample of seismogram.
s = mermaid_sacf('id', sac_diro);
for i = 1:length(s)
    [~, h{i}] = readsac(s{i});
    [~, ~, seis_datenum] = seistime(h{i});
    first_sample(i) = seis_datenum.B;
    
end
[first_sample, idx] = sort(first_sample);
s = s(idx);
h = h(idx);

% Load EQ and CP structures in order and compute travel-time residuals.
tres_time = NaN(length(s), 6);
tres_phase = cell(length(s), 6);
twostd = NaN(length(s), 6);
for i = 1:length(s)
    EQ(i) = getevt(s{i}, rematch_diro, false);
    CP(i) = getcp(s{i}, rematch_diro);

    [temp_tres_time, temp_tres_phase] = tres(EQ(i), CP(i), false);
    fs(i) = efes(h{i});
    if fs(i) == 20
        padd_double = [];
        padd_cell = {};
        
    else
        padd_double = [NaN NaN];
        padd_cell = {NaN NaN};
        
    end
    tres_time(i, :) = [padd_double temp_tres_time];
    twostd(i, :) = [padd_double CP(i).ci.M1.twostd];
    tres_phase(i, :) = [padd_cell temp_tres_phase];    
    snrj(i, :) = [padd_double CP(i).SNRj];

end
save(fullfile(rematch_diro, 'EQ.mat'), 'EQ', 'h');
save(fullfile(rematch_diro, 'CP.mat'), 'CP', 's');
save(fullfile(rematch_diro, mfilename), 'tres_time', 'tres_phase', 'twostd', 's', 'fs', 'snrj');
