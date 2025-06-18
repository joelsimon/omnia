function eqdet(EQ, idx)
% EQDET(EQ, idx)
%
% Print EQ details.
%
% Input:
% idx        Earthquake-structure index, e.g., `EQ(idx)`
%
% Output:
% << printout of EQ phase name and true arrival seconds >>
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-Jul-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

EQ = EQ(idx);
for i = 1:length(EQ.TaupTimes)
    fprintf('Phase: %6s    Time: %7.2f\n', ...
            EQ.TaupTimes(i).phaseName, EQ.TaupTimes(i).truearsecs)

end
