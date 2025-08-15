function dist_m = hunga_dist2slope(kstnm, p2t_m, plt)
% dist_m = HUNGA_DIST2SLOPE(kstnm, p2t_m, plt)
%
% Returns distance from HTHH to theoretical P-T conversion point on
% slope. For all stations NOT H11, P0048, P0049 it starts looking after 80 km
% from source (to get to trench); for others it starts looking immediately.
%
% Input:
% kstnm   Station name
% p2t_m   Elevation (negative meters) of P-T conversion on slope (def: -1350)
%
% Output:
% dist_m  Distance in meters to first occurence of elevation on slope
%
% Ex: (H11 vs H03; former has slope immediately at source, latter at distant trench)
%    dist_H11 = HUNGA_DIST2SLOPE('H11S1', -1350, true)
%    dist_H03 = HUNGA_DIST2SLOPE('H03S1', -1350, true)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Aug-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

defval('p2t_m', -1350)
defval('plt', false)

gb = hunga_read_great_circle_gebco;
gb = gb.(kstnm);

d = gb.cum_distkm;
z = gb.gebco_elev;

% Start looking after 80 km (~just before trench) if NOT station to west.
% (I'm ignoring P0057 and R0073; data not used in paper).
if ~contains(kstnm, {'H11' 'P0048' 'P0049'})
    search_idx = nearestidx(d, 80);

else
    search_idx = 1;

end
z_idx = search_idx + find(z(search_idx+1:end) < p2t_m, 1);
dist_m = d(z_idx)*1e3;

if plt
    figure
    ax = axes;
    plot(d, z);
    xlim([0 200]);
    ylim([-6000 0]);
    hold(ax, 'on')
    plot(ax.XLim, [p2t_m p2t_m]);
    plot([dist_m dist_m]/1e3, ax.YLim);
    xlabel('Distance [km]')
    ylabel('Elevation [m]')
    title(kstnm)
    longticks(ax, 3);
    latimes2
    savepdf(sprintf('%s_%s', mfilename, kstnm))

end
