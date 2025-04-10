function [sac, val] = ordersac_geo(sac, meth, sta)
% [sac, val] = ORDERSAC_GEO(sac, meth, sta)
%
% Order based on GEOgraphic characteristics.
%
% Input:
% sac                Cell array of SAC filenames
% meth               Sort method, one of:
%  'gcarc'           Epicentral distance (output value in degrees)
%  'azimuth'         HTHH-to-station azimuth, from ????? and going clockwise
%  'stdp'            Station depth, down is positive (if unknown: 1500 m)
% sta                Reference station (first in list) for "azimuth" option
%                        (def: N0002)
%
% Output:
% sac                Cell array of SAC filenames ordered using requested method
% val                Parameter value used for sort
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

%% NB: recursive; `stdp` method calls `gcarc` method first.

defval('sta', 'N0002')

meth = lower(meth);
switch meth
  case 'gcarc'
    % Great-circle (epicentral) distance.
    evt = load(fullfile(getenv('HUNGA'), 'evt', '11516993.evt'), '-mat');
    EQ = evt.EQ;
    for i = 1:length(sac)
        [~, h] = readsac(sac{i});
        [~, deg(i)] = grcdist([EQ.PreferredLongitude EQ.PreferredLatitude], [h.STLO h.STLA]);

    end
    [val, idx] = sort(deg);
    sac = sac(idx);

  case 'azimuth'
    evt = load(fullfile(getenv('HUNGA'), 'evt', '11516993.evt'), '-mat');
    EQ = evt.EQ;
    for i = 1:length(sac)
        [~, h] = readsac(sac{i});
        az(i) = azimuth(EQ.PreferredLatitude, EQ.PreferredLongitude, h.STLA, h.STLO);
        %az(i) = azimuth(h.STLA, h.STLO, EQ.PreferredLatitude, EQ.PreferredLongitude); % BAZ
        kstnm{i} = h.KSTNM;

    end
    % Prelim sort by azimuth.
    [val, idx] = sort(az);
    kstnm = kstnm(idx);
    sac = sac(idx);

    % Maybe split deck and start at different station.
    sta_idx = cellstrfind(kstnm, sta);
    idx = [sta_idx:length(kstnm) 1:sta_idx-1];
    val = val(idx);
    sac = sac(idx);

  case 'stdp'
    sac = ordersac_geo(sac, 'gcarc');
    for i = 1:length(sac)
        [~, h] = readsac(sac{i});
        stdp(i) = -h.STDP;
        if stdp(i) == -12345 || isnan(stdp(i))
            error(sprintf('Undefined depth for %s', h.KSTNM))

        end
    end
    [val, idx] = sort(stdp);
    sac = sac(idx);

  otherwise
    error('bad meth')

end
