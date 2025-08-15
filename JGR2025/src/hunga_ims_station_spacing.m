function hunga_ims_station_spacing
% HUNGA_IMS_STATION_SPACING
%
% Print distances between IMS hydrophones within each triad, and distance
% between N and S triads based on average lat/lon of both.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Feb-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

clc

hundir = getenv('HUNGA');
fname = fullfile(hundir, 'sac', 'meta', 'loc.txt');
fmt = '%5s    %10.6f    %11.6f    %6d\n';
fid = fopen(fname, 'r');
C = textscan(fid, fmt, 'Headerlines', 1);
fclose(fid);

kstnm = C{1};
stla = C{2};
stlo = C{3};
stdp = C{4};

interdist('H03N', kstnm, stla, stlo)
interdist('H03S', kstnm, stla, stlo)
interdist('H11N', kstnm, stla, stlo)
interdist('H11S', kstnm, stla, stlo)
outerdist('H03N', 'H03S', kstnm, stla, stlo);
outerdist('H11N', 'H11S', kstnm, stla, stlo);

%% ___________________________________________________________________________ %%
function interdist(char4, kstnm, stla, stlo)
% Inter-triad distance, e.g., between H03S1 and H03S1

h_idx = cellstrfind(kstnm, char4);
h_kstnm = kstnm(h_idx);
h_combo = nchoosek(h_kstnm, 2);
for i = 1:length(h_combo)
    kstnm1 = h_combo{i,1};
    kstnm2 = h_combo{i,2};

    idx1 = cellstrfind(kstnm, kstnm1);
    idx2 = cellstrfind(kstnm, kstnm2);

    stla1 = stla(idx1);
    stlo1 = stlo(idx1);

    stla2 = stla(idx2);
    stlo2 = stlo(idx2);

    distkm = grcdist([stlo1 stla1], [stlo2 stla2]);
    fprintf('%s --> %s: %6.2f km\n', kstnm1, kstnm2, distkm)

end

%% ___________________________________________________________________________ %%
function outerdist(char4_1, char4_2, kstnm, stla, stlo)
% Between-triad distance, e.g., from (average) H03S* to (average) H03N*

char4_1_idx = cellstrfind(kstnm, char4_1);
char4_1_stla = mean(stla(char4_1_idx));
char4_1_stlo = mean(stlo(char4_1_idx));

char4_2_idx = cellstrfind(kstnm, char4_2);
char4_2_stla = mean(stla(char4_2_idx));
char4_2_stlo = mean(stlo(char4_2_idx));

fprintf('%s* --> %s*: %6.2f km\n', char4_1, char4_2, ....
        grcdist([char4_1_stlo char4_1_stla], [char4_2_stlo char4_2_stla]))
