function eqdet(EQ, idx)
% EQDET(EQ, idx)
%
% Print EQ details.
%
% Input:
% idx        Earthquake-structure index(s), e.g., `EQ(idx)`
%
% Output:
% << printout of EQ phase name and true arrival seconds >>
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Oct-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

%% RECURSIVE
if length(idx) > 1
    for i = 1:length(idx)
        eqdet(EQ, idx(i))
        fprintf('\n')

    end
    return

end

fprintf('EQ(%i)\n', idx)
EQ = EQ(idx);
for i = 1:length(EQ.TaupTimes)
    fprintf('Phase: %6s    Time: %7.2f\n', ...
            EQ.TaupTimes(i).phaseName, EQ.TaupTimes(i).truearsecs)

end
