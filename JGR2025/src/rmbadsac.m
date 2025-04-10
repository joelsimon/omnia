function sac = rmbadsac(sac)
% sac = RMBADSAC(sac)
%
% Removes corrputed/bad data SAC files.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 28-Jun-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Serial numbers of bad .sac
bad_sac = {'\.12_', ...
           '\.0027_', ...
           '\.0032_', ...
           '\.0033_', ...
           '\.0038_', ...
           '\.0052_', ...
           'H03N3'};

rm_idx = [];
for i = 1:length(bad_sac)
    rm_idx = [rm_idx ; cellstrfind(sac, bad_sac{i})];

end
sac(rm_idx) = [];
