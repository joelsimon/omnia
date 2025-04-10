function sac = rmgapsac(sac)
% sac = RMGAPSAC(sac)
%
% Remove gappy (incomplete) SAC files.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Remove gappy .sac
gappy_sac = {'0057', ...
             '0073'};
for i = 1:length(gappy_sac)
    sac(cellstrfind(sac, gappy_sac{i})) = [];

end
