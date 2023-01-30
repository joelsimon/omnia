function comparesactimes(sac1, sac2)
% COMPARESACTIMES(sac1, sac2)
%
% Print start/endtimes of two SAC files for comparision.
%
% Input:
% sac1/2      SAC filenames
%
% Output:
% [printout to command window]
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Oct-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
sac = {sac1 sac2};
for i = 1:2
    [~, h(i)] = readsac(sac{i});
    sd(i) = seistime(h(i));

end

fprintf('(1) %s\n', strippath(sac1))
fprintf('(2) %s\n\n', strippath(sac2))

fprintf('(1) Start: %s\n', sd(1).B);
fprintf('(2) Start: %s (%+i s)\n\n', sd(2).B, round(seconds(sd(2).B - sd(1).B)));

fprintf('(1)  End: %s\n', sd(1).E);
fprintf('(2)  End: %s (%+i s)\n', sd(2).E, round(seconds(sd(2).E - sd(1).E)));
