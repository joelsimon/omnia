function hunga_ims_station_location_update()
% HUNGA_IMS_STATION_LOCATION_UPDATE
%
% One-time use function to update IMS SAC files with updated latitude,
% longitude, station elevation and station depth.
%
% Does not also update text files output wit that info, e.g., gcarc.txt --
% will have to rerun those generatoring functions.
%
% STDP is positive measured from ocean surface to hydrophone in meters.
% STEL is negative measured from ocean surface seafloor in meters.
%
% So both measure down from surface, but STDP increases with my initutive
% definition of depth, and STEL decreases with my intutitive defintion of
% depth.
%
% Ex: H03N1, STEL = -1538, STDP = 812 => the hydrophone is 812 meters below
% the surface in a 1538-deep ocean.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

sacdir = fullfile(getenv('HUNGA'), 'sac')
txt  = fullfile(sacdir, 'meta', 'ims_station_location_update.txt');
fid = fopen(txt, 'r');

fmt = '%s %f %f %f %f';
tscan = textscan(fid, fmt, 'HeaderLines', 1, 'Delimiter', ' ', 'MultipleDelimsAsOne', true);
fclose(fid);

% Format is: KSTNM, STLA, STLO, STEL (-km), STDP (+km)
KSTNM = tscan{1};
STLA = tscan{2};
STLO = tscan{3};
STEL = tscan{4}*1000; % convert to meters
STDP = tscan{5}*1000; % convert to meters

dotsac = globglob(sacdir, 'ims', '*.sac'); % raw
dotpa = globglob(sacdir, 'ims', '*.sac.pa'); % instrument reponse removed
all_sac = [dotsac ; dotpa];

for i = 1:length(KSTNM)
    % Identify which .sac we are working with.
    sac_idx = cellstrfind(all_sac, KSTNM{i});

    % Loop this because there is raw "*.sac" and instrument-response-removed "*.sac.pa".
    for j = 1:length(sac_idx);
        sac = all_sac{sac_idx(j)};

        % Read data and header (to be overwritten).
        [x, h] = readsac(sac);

        % Overwrite header vars.
        h.STLA = STLA(i);
        h.STLO = STLO(i);
        h.STEL = STEL(i);
        h.STDP = STDP(i);

        % Save modified header.
        writesac(x, h, sac)
        fprintf('Updated: %s\n', strippath(sac));

    end
end
