function figS10_thru_S44
% FIGS10_THRU_S44
%
% Figures SI 1-35: Time domain, spectral domain, bathymetric cross section,
% Fresnel-zone bathymetry map view.
%
% Wrapper for fig4_5_A2, inputting all SAC in order of epicentral distance.
% There, no individual sac files should be called internally (comment all
% lines starting with `sac = ...`), and timspec_only must be false.
%
% Developed as: hunga_timspecprofbath2_all then figSI1_35.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

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
    [ax, f] = fig3_4l_S4(sac{i}); % see this subfunc to properly set up preamble
    h = sachdr(sac{i});
    savepdf(sprintf('%02i_%s', i, h.KSTNM));
    close

end
