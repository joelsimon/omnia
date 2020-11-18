function [tot, surf, deep] = driftstats(gps, name, surftime, deeptime)
% [tot, surf, deep] = DRIFTSTATS(gps, name, surftime, deeptime)
%
% Return drift statistics by leg, and in sum/average, broken down by surface and deep-drift
% components (in SI units of meters and seconds).
%
% NB, surface- and deep-drift leg-segment GPS pairs (see note after I/O description) do not
% necessarily span the complete set of all leg-segment pairs because they depend on the choice of
% 'surftime' and 'deeptime' -- indeed they may even overlap if those parameters are chosen poorly.
%
% Input:
% gps         GPS structure from readgps.m
% name        Char name of MERMAID (e.g., 'P008'; fieldname in gps)
% surftime     Maximum time difference between two GPS points to be considered surface drift [s]
%                 (def: 3600)
% deeptime    Minimum time difference between two GPS points to be considered deep drift [s]
%                 (def: 6.5*3600)
% Output:
% tot         Drift statistics using every GPS point
% surf        Drift statistics of surface drift
% deep        Drift statistics of deep drift
%
% Each output structure returns the sums/means of these statistics, and breaks them by individual
% leg (segments between GPS points).  The index matrix, '.idx,' attached to each are "leg-segment
% GPS pairs," and they reference the complete list of locations and dates in gps.
%
% I.e., for P008
%
%     deep.idx(1,:) = [4 5]
%
% meaning that the first deep-drift leg occurred between the dates of
%
%     gps.P008.locdate(4:5) = [2018-08-05T13:32:46Z  2018-08-06T13:47:20Z]'
%
% See also: readgps.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 18-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default surface/deep drift time differences: it takes approximately 6.5 hrs to descend and ascend
% back to surface at 500 m parking depth.
defval('surftime', 3600);
defval('deeptime', 6.5*3600)

% Parse relevant GPS fields.
gps = gps.(name);
lat = gps.lat;
lon = gps.lon;
locdate = gps.locdate;

leg_time = seconds(diff(locdate));
leg_time = [0 ; leg_time];

% Compute leg-pair indices -- these reference the complete list in mer.(name).
idx = 1:length(locdate);
tot.idx = [idx'-1 idx'];
tot.idx(1,1) = 1;    % otherwise tot.idx(1,1,) = 0; index out of bounds (makes a zero-time [1 1]  leg)

short_time = find(leg_time < surftime);
surf.idx = [short_time-1 short_time];
if surf.idx(1,1) == 0
    surf.idx(1,1) = 1;

end

long_time = find(leg_time > deeptime);
deep.idx = [long_time-1 long_time];
if deep.idx(1,1) == 0
    deep.idx(1,1) = 1;

end

% Compute statistics using those leg-pair indices.
[tot.dist, tot.time, tot.vel, tot.tot_dist, tot.ave_dist, tot.tot_time, tot.ave_time, tot.ave_vel] ...
    = dtv(tot.idx, lat, lon, locdate);

[surf.dist, surf.time, surf.vel, surf.tot_dist, surf.ave_dist, surf.tot_time, surf.ave_time, surf.ave_vel] ...
    = dtv(surf.idx, lat, lon, locdate);

[deep.dist, deep.time, deep.vel, deep.tot_dist, deep.ave_dist, deep.tot_time, deep.ave_time, deep.ave_vel] ...
    = dtv(deep.idx, lat, lon, locdate);


%%______________________________________________________________________________________%%

function [dist, time, vel, tot_dist, ave_dist, tot_time,  ave_time, ave_vel] ...
    = dtv(idx, lat, lon, locdate)
% Returns distances, times, and velocities meters, seconds, and meters per second.

deg = distance(lat(idx(:,2)), lon(idx(:,2)), lat(idx(:,1)), lon(idx(:,1)));
dist = deg2km(deg) * 1000;
time = seconds(locdate(idx(:,2)) - locdate(idx(:,1)));

% Issue: division by zero.
% Solution: replace time = 0 with NaNs, divide, slot 0 back into same indices.
zero_time = find(time==0)
time(zero_time) = NaN;
vel = dist ./ time;
time(zero_time) = 0;

tot_deg = sum(deg);
ave_deg = nanmean(deg);

tot_dist = sum(dist);
ave_dist = nanmean(dist);

tot_time = sum(time);
ave_time = nanmean(time);

ave_vel = nanmean(vel);
keyboard