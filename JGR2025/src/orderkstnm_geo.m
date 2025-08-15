function [kstnm, val, sac] = orderkstnm_geo(kstnm, meth, sta)
% [kstnm, val, sac] = ORDERKSTNM_GEO(kstnm, meth, sta)
%
% Order based on GEOgraphic characteristics.
%
% Input:
% kstnm       Cell array of five-character station names
% meth        Sort method, one of:
%  'gcarc'        Epicentral distance (output value in degrees)
%  'azimuth'      HTHH-to-station azimuth, from ????? and going clockwise
%  'stdp'         Station depth, down is positive (if unknown: 1500 m)
% sta             Reference station (first in list) for "azimuth" option
%                     (def: N0002)
% Output:
% kstnm       Cell array of KSTNM filenames ordered using requested method
% val         Parameter value used for sort
% idx         Index array s.t. input_kstnm(idx) = output_kstnm
% sac         Full SAC filename
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 09-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

gc = hunga_read_great_circle;
fnames = fieldnames(gc);
defval('kstnm', fnames);
defval('sta', 'N0002');

sac = hunga_fullsac;
kstnm2 = sackstnm(sac);
keyboard
idx = ismember(kstnm2, kstnm);
sac = sac(find(idx));

[sac, val] = ordersac_geo(sac, meth, sta);
if isempty(sac)
    error('Ordering returned no results (azimuth using station not in list?)')

end
kstnm = sackstnm(sac);
if isrow(sac); sac = sac'; end
if isrow(val); val = val'; end
if isrow(kstnm); kstnm = kstnm'; end
