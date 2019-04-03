% Script to write travel-time residuals for all JDS-identified,
% Princeton MERMAID SAC files, assuming JDS system defaults.
%
% Requires you've first run writechangepointall.m
%
% Allows tres computation considering "first" EQ (EQ(1)) only.
%
% Sends output tres.mat to: /home/jdsimon/mermaid/events/reviewed/identified/
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Apr-2019, Version 2017b

close all
clear 

% Load the reviewed data. 
s = revsac(1);
first_sample = NaN(length(s), 1);
parfor i = 1:length(s)
    [~, h] = readsac(fullsac(s{i}));
    [~, ~, seis_datenum] = seistime(h);
    first_sample(i) = seis_datenum.B;
    
end
[first_sample, idx] = sort(first_sample);
s = s(idx);

% Load EQ and CP structures in order and compute travel-time residuals.
tres_time = NaN(length(s), 6);
tres_phase = cell(length(s), 6);
twostd = NaN(length(s), 6);
ave = NaN(length(s), 6);
snrj = NaN(length(s), 6); 

parfor i = 1:length(s)
    i
    EQ = getevt(s{i});
    CP = getcp(s{i});
    if isempty(CP)
        error('CP structure empty.\nRun writechangepointall.m')

    end

    % Allow tres.m computation along first EQ only.
    [temp_tres_time, temp_tres_phase] = tres(EQ, CP, false);

    tres_time(i, :) = [temp_tres_time];
    tres_phase(i, :) = [temp_tres_phase];    
    twostd(i, :) = [CP.ci.M1.twostd]; 
    ave(i, :) = [CP.ci.M1.ave];
    snrj(i, :) = CP.SNRj;

end
diro = fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified');
save(fullfile(diro, 'tres.mat'), 's', 'tres_time', 'tres_phase', 'twostd', 'ave', 'snrj');
