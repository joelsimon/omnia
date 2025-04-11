function figSI1_35
% FIGSI1_35
%
% Figures SI 1-35: Time domain, spectral domain, bathymetric cross section,
% Fresnel-zone bathymetry map view.
%
% Wrapper for fig4_5_A2, inputting all SAC in order of epicentral distance.
% There, no individual sac files should be called internally (comment all
% lines starting with `sac = ...`), and timspec_only must be false.
%
% Developed as: hunga_timspecprofbath2_all

% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 12-Feb-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');

sac = globglob(sacdir, '*.sac');
imssac = globglob(imsdir, '*sac.pa');

sac = [sac ; imssac];

sac = rmbadsac(sac);
sac = rmgapsac(sac);
sac = ordersac_geo(sac, 'gcarc');

%% To order by occlusion (let's not)
% for i = 1:length(sac)
%     h = sachdr(sac{i});
%     kstnm{i} = h.KSTNM;
% end
%[kstnm, val, idx] = orderkstnm_occl(kstnm, -1350, 1, 1.0, false);
%sac = sac(idx);

for i = 1:length(sac)
    % NB: `fig4_5_A2` was originally `hunga_timspecprofbath2`
    [ax, f] = fig4_5_A2(sac{i});
    h = sachdr(sac{i});
    savepdf(sprintf('%02i_%s', i, h.KSTNM));
    close

end
