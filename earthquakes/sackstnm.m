function kstnm = sackstnm(sac)
% kstnm = SACKSTNM(sac)
%
% Return cell array of SAC header fields KSTNM (five-character station name).
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 21-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Recursion
if iscell(sac)
    for i = 1:length(sac)
        kstnm{i} = sackstnm(sac{i});

    end
    if ~isrow(sac)
        kstnm = kstnm';

    end
    return

end

% Main
h = sachdr(sac);
kstnm = h.KSTNM;