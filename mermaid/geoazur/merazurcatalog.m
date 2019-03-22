% Script to writes updated GeoAzur MERMAID catalog assuming JDS' system defaults.
%
% Step 1:
% Rematch earthquakes: rematch_merazur.m
%
% Step2: Review those rematchs: review_rematch
%
% Step 3: Compute changepoints and their confidence intervals:
% writechangepoint_merazur.m
%
% Step 4: Run this script to produce output text file:
% $MERMAID/events/geoazur/catalog.txt

close all
clear all

% Output catalog filename.
evt_diro = fullfile(getenv('MERMAID'), 'events', 'geoazur', 'evt');
evt_diro = fullfile(getenv('MERMAID'), 'events', 'geoazur', 'evt');

filename = fullfile(getenv('MERMAID'), 'events', 'geoazur', 'catalog.txt');

% Load all seismograms and sort them into order of 
s = mermaid_sacf('id');


%% Sort the seismograms based on the UTC time of the first sample.

for i = 1:length(s)
    [~, h{i}] = readsac(s{i});
    [seis_date{i}, ~, seis_datenum, ~, original_evtdate{i}] = seistime(h{i});
    first_sample(i) = seis_datenum.B;
    
end

[first_sample, idx] = sort(first_sample)
s = s(idx);
seis_date = seis_date(idx);


%% Load the EQ and CP structures.





