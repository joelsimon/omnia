function kstnm = sackstnm(sac)
% kstnm = SACKSTNM(sac)
%
% Return cell array of SAC header fields KSTNM (five-character station name)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

for i = 1:length(sac)
    h = sachdr(sac{i});
    kstnm{i} = h.KSTNM;

end
