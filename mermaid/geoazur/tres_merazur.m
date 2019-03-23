% Script to compute travel time residuals between all phases
% considered for rematched events as initially reported by GeoAzur, and
% JDS' changepoint estimates.
%
% Assumes JDS' system defaults (e.g., paths and environmental variables).
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Mar-2019, Version 2017b

close all
clear all

% Directories to find .sac, .evt, and .cp files.
base_diro = fullfile(getenv('MERMAID'), 'geoazur');
rematch_diro = fullfile(base_diro, 'rematch');

s = mermaid_sacf('id', base_diro);

tres_time = NaN(length(s), 6);

% Load rematched and reviewed EQ and CP structures.
for i = 1:length(s)
    EQ = getevt(s{i}, rematch_diro);
    CP = getcp(s{i}, rematch_diro);

    % I've manually verified every GeoAzur event and ensured each reviewed
    % .evt file includes only a single event.  Therefore, set 'multi'
    % input in tres.m to false.
    
    [temp_tres_time, tres_phase, tres_EQ] = tres(EQ, CP, false);
    
    if round(1 / CP.inputs.delta) == 5
        padd = [NaN NaN];

    else
        padd = [];

    end

    tres_time(i, :) = [padd temp_tres_time];

end

for i = 1:6
    figure
    
    histogram(tres_time(:,i), 'BinLimits', [-10 10], 'BinMethod', 'Integer')
    title(sprintf('Scale: %i Mean: %.3f', i, nanmean(tres_time(:,i))));
    
end

