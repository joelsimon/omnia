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
% surftime*   Maximum time difference between two GPS points to be considered surface drift [s]
%                 (def: 3600)
% deeptime    Minimum time difference between two GPS points to be considered deep drift [s]
%                 (def: 6.5*3600)
% Output:
% tot         Drift statistics using every GPS point
% surf        Drift statistics of surface drift
% deep        Drift statistics of deep drift
%
% *NB, GPS fixes taken with 60 s of one another are not considered when estimating surface drift.
%
% Each output structure returns the sums/means of these statistics, and breaks them down by
% individual leg (segments between GPS points).  The index matrix, '.idx,' attached to each are
% "leg-segment GPS pairs," and they reference the complete list of locations and dates in gps.
%
% I.e., for P008
%
%     deep.idx(1,:) = [4 5]
%
% meaning that the first deep-drift leg occurred between the dates of
%
%     gps.P008.locdate(4:5) = [2018-08-05T13:32:46Z  2018-08-06T13:47:20Z]
%
% See also: readgps.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default surface/deep drift time differences: it takes approximately 6.5 hrs to descend and ascend
% back to surface at 500 m parking depth.
defval('surftime', 3600);
defval('deeptime', 6.5*3600)

% Parse relevant GPS fields.
gps = gps.(name);
lat = gps.lat;
lon = gps.lon;
locdate = gps.locdate;

% Compute the time difference between each GPS fix.
leg_time = seconds(diff(locdate));
leg_time = [0 ; leg_time];

%%______________________________________________________________________________________%%
%% Considering ALL GPS fixes
%%______________________________________________________________________________________%%

% Compute leg-pair indices -- these reference the complete list in mer.(name).
idx = 1:length(locdate);
tot.idx = [idx'-1 idx'];
tot.idx(1,1) = 1;    % otherwise tot.idx(1,1,) = 0; index out of bounds (makes a zero-time [1 1] leg)

% Leg-pairs are defined by the SECOND COLUMN (which matches lat/lon/locdate indexing):
%
% 1st leg: indices [1   1] (null; no time difference)
% 2nd leg: indices [1   2]
% 3rd leg: indices [2   3]
% ...
% Nth leg: indices [N-1 N]
% Nth + 1: indices [N N+1]  (Nth index of lat seen in Nth and Nth+1 index of tot.idx)

% We need to be careful about P023 because it was out of the water on some dates.
if strcmp(name, 'P023')
    bad_dates = iso8601str2date({'2019-08-17T03:18:29Z' '2019-08-17T03:22:02Z'});
    [~, bad_idx] = intersect(locdate, bad_dates);

    % Insert NaNs as opposed to removing the values to maintain the same indexing.
    lat(bad_idx) = NaN;
    lon(bad_idx) = NaN;
    locdate(bad_idx) = NaT;
    leg_time(bad_idx) = NaN;
    tot.idx(bad_idx,:) = NaN;

end

%%______________________________________________________________________________________%%
%% Considering GPS fixes while drifting at the surface
%%______________________________________________________________________________________%%
short_time = find(leg_time<surftime & leg_time>60);
surf.idx = [short_time-1 short_time];
if surf.idx(1,1) == 0
    surf.idx(1,1) = 1;

end

%%______________________________________________________________________________________%%
%% Considering GPS fixes while drifting in the mixed layer
%%______________________________________________________________________________________%%

long_time = find(leg_time>deeptime);
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

% Find any non-finite indices (removed in P023)
[~, nan_idx] = unzipnan(idx(:, 2));

% Replace those indices with dummies so that they may be referenced as actual lat/lon and locdate
% indices: just use 1 (this means that the 'deg' and 'time' computations will temporarily reference
% the first lat/lon or locdate); we'll slot NaNs back into those indices below.
idx(nan_idx,:) = 1;

% Compute degrees traveled and time spend on each leg.
deg = distance(lat(idx(:,2)), lon(idx(:,2)), lat(idx(:,1)), lon(idx(:,1)));
time = seconds(locdate(idx(:,2)) - locdate(idx(:,1)));

% Replace indices that were temporarily set to 1 back to NaN.
deg(nan_idx) = NaN;
time(nan_idx) = NaN;

% Now this value is legit (DO NOT do this before NaN replacement, directly above).
dist = deg2km(deg) * 1000;

% Issue: division by zero.
% Solution: replace time = 0 with NaNs, divide, slot 0 back into same indices.
zero_time = find(time==0);
time(zero_time) = NaN;
vel = dist ./ time;
time(zero_time) = 0;

tot_deg = nansum(deg);
ave_deg = nanmean(deg);

tot_dist = nansum(dist);
ave_dist = nanmean(dist);

tot_time = nansum(time);
ave_time = nanmean(time);

ave_vel = nanmean(vel);
