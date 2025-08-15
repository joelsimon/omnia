function compare_mhpz()
% COMPARE_MHPZ()
%
% Compare HTHH waveforms after fixing DMC poles and zeros.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Jun-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');
staticdir = fullfile(hundir, 'code', 'static');
respdir = fullfile(getenv('MERMAID'), 'response');

sac = globglob(sacdir, '*.sac');
imssac = globglob(imsdir, '*sac.pa');
sac = [sac ; imssac];

sac = rmbadsac(sac);
sac = rmgapsac(sac);
sac = keepsigsac(sac);

pz_old = fullfile(respdir, 'dmc_error', 'MH_error.pz');
pz_new = fullfile(respdir, 'MH.pz');

for i = 1:length(sac)
    if isimssac(sac{i})
        continue

    end

    [x_old, h_old] = hunga_transfer_bandpass(sac{i}, [], [], pz_old);
    [x_new, h_new] = hunga_transfer_bandpass(sac{i}, [], [], pz_new);

    plot(x_old);
    hold on
    plot(x_new);

    corr(x_old, x_new)

    pause
    close

end
