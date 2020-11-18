function D = driftstats2
% D = DRIFTSTATS2
%
% Input:
% processed     Processed directory output by automaid
%                   (def: $MERMAID/processed)
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default path.
merpath = getenv('MERMAID');
defval('name', 'P008')
defval('processed', fullfile(merpath, 'processed'))


mer = readgps(processed);
mer = mer.(name);
lat = mer.lat;
lon = mer.lon;
locdate = mer.locdate;

leg_time = seconds(diff(locdate));
leg_time = [0 ; leg_time];

% Split into surface and deep drift (> 6.5 hrs, approx. time to descend and ascend back to
% surface at 500 m parking depth)
long_time = find(leg_time > 6.5*3600);
deep_idx = [long_time-1 long_time];

% Alternatively: short_time = setdiff(1:length(locdate), time_jump)';
short_time = find(leg_time < 3600);
surf_idx = [short_time-1 short_time];
surf_idx(surf_idx == 0) = 1;

% Then do it by leg pairs
surf_dist = deg2km(distance(lat(surf_idx(:,2)), lon(surf_idx(:,2)), ...
                            lat(surf_idx(:,1)), lon(surf_idx(:,1))));
surf_dist = sum(surf_dist) * 1000;

deep_dist = deg2km(distance(lat(deep_idx(:,2)), lon(deep_idx(:,2)), ...
                            lat(deep_idx(:,1)), lon(deep_idx(:,1))));
deep_dist = sum(deep_dist) * 1000;

surf_time = sum(seconds(locdate(surf_idx(:,2)) - locdate(surf_idx(:,1))));
deep_time = sum(seconds(locdate(deep_idx(:,2)) - locdate(deep_idx(:,1))));

surf_vel = surf_dist / surf_time;
deep_vel = deep_dist / deep_time; 
