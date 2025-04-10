function [sac_kstnm, idx] = keepsigsac(sac_kstnm)
% [sac_kstnm, idx] = KEEPSIGSAC(sac_kstnm)
%
% Signal category A and B.
%
% Input:
% sac_kstnm    SAC filename -OR- 5-char KSTNM
% idx          Index array s.t. input_sac_kstnm(idx) = output_sac_kstnm
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Sep-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

C = catsac;
idx = [];
for i = 1:length(sac_kstnm)
    if endsWith(sac_kstnm{i}, {'.sac' '.sac.pa'}, 'IgnoreCase', true)
        h = sachdr(sac_kstnm{i});
        kstnm = h.KSTNM;

    else
        kstnm = sac_kstnm{i};

    end
    if strcmp(C.(kstnm), 'A') || strcmp(C.(kstnm), 'B')
        idx = [idx; i];

    end
end
sac_kstnm = sac_kstnm(idx);
