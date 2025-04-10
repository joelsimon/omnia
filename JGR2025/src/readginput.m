function gap = readginput(sac)
% gap = READGINPUT(sac)
%
% Read indices of local events to be cut, manually identified with writeginput.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Sep-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

gap = [];
staticdir = fullfile(getenv('HUNGA'), 'code', 'static');
[~, h] = readsac(sac);
f = fullfile(staticdir, sprintf('%s_ginput.txt', h.KSTNM));
if exist(f, 'file') ~= 2
    return

end

samp_pair = load(f);
if mod(length(samp_pair), 2) ~= 0
    error('Expecting sample pairs (that define gap edges).\nRepick with `writeginput`')

end

% Wow this is ugly but I want to go on a walk...
samp_mat = reshape(samp_pair, 2, length(samp_pair)/2)';
for i = 1:size(samp_mat, 1)
    gap{i} = samp_mat(i, :);

end
