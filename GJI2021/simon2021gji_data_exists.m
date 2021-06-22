function simon2021gji_data_exists
% SIMON2021GJI_DATA_EXISTS
%
% This returns how many traces / events are contained in
% nearbystations and cpptstations for all MERMAID events corresponding
% to DET files, through the end of 2019.
%
% NB, set readidentified 'returntype' to 'ALL' to see all 1565 SAC
% (290 events) actually contained in the cpptstations folder, because I
% don't use all those because some events correspond only to REQ
% MERMAID files.
%
% Also, there are more NEARBY SAC files (if you ls */AM*SAC) there than are
% returned here because those data go into 2020.
%
% Developed as: ./scriptish/simon2020_data_exists.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

% Ensure in GJI21 git branch.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

% Paths to the relevant ID file and other necessary directories.
id_txtfile =  fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified', 'txt', 'identified.txt');
endtime = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');

% Set 'DET' to 'ALL' to see all 290 CPPT events / 1565 SAC files in cpptstations.
[~, ~, ~, ~, ~, ~, ~, ~, ~, id] = ...
    readidentified(id_txtfile, [], endtime, 'SAC', 'DET', false);

% Ignore leading asterisk on event ID (signals possible multi events).
star_idx = cellstrfind(id, '*');
for i = 1:length(star_idx)
    id{star_idx(i)}(1) = [];

end
id = unique(id); % mer_data_exists

%% The "nearby" folder contains two instrument types: raditional and Raspberry Shake.
%% The CPPT folder contains one instrument type: traditional.

num_nb_sac = 0;
num_nb_evt = 0;
num_nb_rasp_sac = 0;
num_nb_rasp_evt = 0;
num_nb_trad_evt = 0;
nb_trad_data_exists = {};
nb_rasp_data_exists = {};

num_cp_sac = 0;
num_cp_evt = 0;
cp_trad_data_exists = {};

for i = 1:length(id)
    try % this ID directory may not exist
        nb_sac = getnearbysac(id{i}, []);

        num_nb_evt = num_nb_evt + 1;

        num_nb_sac_this_evt = length(nb_sac);
        num_nb_sac = num_nb_sac + num_nb_sac_this_evt;

        num_nb_rasp_sac_this_evt = length(cellstrfind(nb_sac, 'AM\.R.*\.SAC'));
        if num_nb_rasp_sac_this_evt > 0
            num_nb_rasp_evt = num_nb_rasp_evt + 1;
            num_nb_rasp_sac = num_nb_rasp_sac + num_nb_rasp_sac_this_evt; % *See note at bottom
            nb_rasp_data_exists = [nb_rasp_data_exists ; id{i}];

        end
        if num_nb_sac_this_evt > num_nb_rasp_sac_this_evt
            num_nb_trad_evt = num_nb_trad_evt + 1;
            nb_trad_data_exists = [nb_trad_data_exists ; id{i}];

        end
    end

    try
        cp_sac = getcpptsac(id{i}, []);
        num_cp_evt = num_cp_evt + 1;
        num_cp_sac = num_cp_sac + length(cp_sac);
        cp_trad_data_exists = [cp_trad_data_exists ; id{i}];

    end
end

fprintf('%i unique events ID''d MERMAID\n\n', length(id))

fprintf('%i unique events with "nearby" SAC files from IRIS/affiliates\n', num_nb_evt)
fprintf('%i total SAC files from "nearby" stations from IRIS/affiliates\n\n', num_nb_sac)

fprintf('\tNearby "traditional:" %i unique events\n', num_nb_trad_evt);
fprintf('\tNearby "traditional:" %i SAC files\n\n', num_nb_sac - num_nb_rasp_sac);

fprintf('\tNearby Raspbery Shake: %i unique events\n', num_nb_rasp_evt);
fprintf('\tNearby Raspbery Shake: %i SAC files\n\n', num_nb_rasp_sac);

fprintf('%i unique events with CPPT SAC files from Olivier Hyvernaud\n', num_cp_evt)
fprintf('%i total SAC files from CPPT stations from Olivier Hyvernaud\n\n', num_cp_sac)

% The total "traditional" stations are those in the "nearby" and CPPT folders
trad_data_exists = unique([nb_trad_data_exists ; cp_trad_data_exists]);
datadir = fullfile(getenv('GJI21_CODE'), 'data');

% Write file listing the events for which MERMAID data exists.
filename = fullfile(datadir, 'data_exists.mer.txt');
fid = fopen(filename, 'w');
fprintf(fid, '%s\n', id{:});
fprintf('Wrote: %s\n', filename);

% Write file listing the events for which traditional island station data exists.
filename = fullfile(datadir, 'data_exists.trad.txt');
fid = fopen(filename, 'w');
fprintf(fid, '%s\n', trad_data_exists{:});
fprintf('Wrote: %s\n', filename);

% Write file listing the events for which Raspberry Shake island station data exists.
filename = fullfile(datadir, 'data_exists.rasp.txt');
fid = fopen(filename, 'w');
fprintf(fid, '%s\n', nb_rasp_data_exists{:});
fprintf('Wrote: %s\n', filename);

% *Notes to verify RASP:
%
% $ cd $MERMAID/events/nearbystations/sac
% $ ls */AM.R*SAC > k
%
% open k and remove all SAC files from 2020 and you get 420, as here.
