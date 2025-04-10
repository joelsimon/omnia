function [kstnm, sac] = lskstnmcat(sigcat)
% [kstnm, sac] = LSKSTNMCAT(sigcat)
%
% Return list of station names based on signal category.
%
% Input:
% sigcat  0: category A, B, and C signal (35 stations)
%         1: only category A and B signals (yes signal; 29 stations) [def]
%         2: only category C stations (no signal; 6 stations);
%
% Output:
% kstnm   List of station names
% sac     List of SAC filenames
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 28-Feb-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Default.
defval('sigcat', 1)

% Paths.
hundir = getenv('HUNGA');
sacdir = fullfile(hundir, 'sac');
imsdir = fullfile(sacdir, 'ims');
imssac = globglob(imsdir, '*sac.pa');
staticdir = fullfile(hundir, 'code', 'static');

% Determine which SAC files to keep.
sac = globglob(sacdir, '*.sac');
imssac = ordersac_geo(imssac, 'gcarc');
allsac = [sac ; imssac];
allsac = rmbadsac(allsac);
allsac = rmgapsac(allsac);
switch sigcat
  case 0
    sac = allsac;

  case 1
    sac = keepsigsac(allsac);

  case 2
    sac = setdiff(allsac, keepsigsac(allsac));

end

% Get list of surviving station names.
kstnm = sackstnm(sac);
