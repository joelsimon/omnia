function verify_orderkstnm_occl()
% VERIFY_ORDERKSTNM_OCCL
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

fg = hunga_read_fresnelgrid_gebco('H11S3', 2.5);
z = fg.depth_m;
tz = -1385;

%% ___________________________________________________________________________ %%
%% Algo 2 will not be the same (occluded halves add 0.5)
fprintf('Test #1\n')
algo = [1 4];
crat = 1.0;
prev = false;
los = false;
for i = 1:length(algo)
    [kstnm{i}, val{i}] = orderkstnm_occl([], tz, algo(i), crat, prev, los);

end
% NB: these indices refer to algo index, not algo number itself (2=4, here)
if ~isequal(kstnm{1}, kstnm{2}); error(''); end
if ~isequal(val{1}, val{2}); error(''); end
for i = 1:length(kstnm{i});
    fprintf('%s: %.1f\n', kstnm{1}{i}, val{1}(i));

end

%% ___________________________________________________________________________ %%
%% Algo 2 will not be the same (occluded halves add 0.5)
fprintf('Test #2\n')
algo = [1 4];
crat = 1.0;
prev = true;
los = false;
for i = 1:length(algo)
    [kstnm{i}, val{i}] = orderkstnm_occl([], tz, algo(i), crat, prev, los);

end
% NB: these indices refer to algo index, not algo number itself (2=4, here)
if ~isequal(kstnm{1}, kstnm{2}); error(''); end
if ~isequal(val{1}, val{2}); error(''); end
for i = 1:length(kstnm{i});
    fprintf('%s: %.1f\n', kstnm{1}{i}, val{1}(i));

end

%% ___________________________________________________________________________ %%
%% Algo 2 will be the same (only considering LoS)
fprintf('Test #3\n')
algo = [1 2 4];
crat = 1.0;
prev = false;
los = true;
for i = 1:length(algo)
    [kstnm{i}, val{i}] = orderkstnm_occl([], tz, algo(i), crat, prev, los);

end
% NB: these indices refer to algo index, not algo number itself (3=4, here)
if ~isequal(kstnm{1}, kstnm{2}, kstnm{3}); error(''); end
if ~isequal(val{1}, val{2}, val{3}); error(''); end
for i = 1:length(kstnm{i});
    fprintf('%s: %.1f\n', kstnm{1}{i}, val{1}(i));

end

%% ___________________________________________________________________________ %%
%% Algo 2 will be the same (only considering LoS)
fprintf('Test #4\n')
algo = [1 2 4];
crat = 1.0;
prev = true;
los = true;
for i = 1:length(algo)
    [kstnm{i}, val{i}] = orderkstnm_occl([], tz, algo(i), crat, prev, los);

end
% NB: these indices refer to algo index, not algo number itself (3=4, here)
if ~isequal(kstnm{1}, kstnm{2}, kstnm{3}); error(''); end
if ~isequal(val{1}, val{2}, val{3}); error(''); end
for i = 1:length(kstnm{i});
    fprintf('%s: %.1f\n', kstnm{1}{i}, val{1}(i));

end

fprintf('All tests passed.\n');
