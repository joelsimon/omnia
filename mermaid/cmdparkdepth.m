function cmdparkdepth(park_depth, dive_duration, descent_speed, ascent_speed, ...
                      pressure_tolerance)
% CMDPARKDEPTH(park_depth, dive_duration, descent_speed, ascent_speed, pressure_tolerance)
%
% CMDPARKDEPTH returns the "stage" commands for a MERMAID .cmd file given a
% parking depth (in meters) and a total dive duration (in minutes).
%
% It is only able to program simple two-stage missions:
% *stage 1 = descent
% *stage 2 = acquisition (at parking depth).
% NB, the ascent is not considered a "stage" for .cmd purposes.
%
% It assumes a single descent speed and the same depth tolerance for both
% stages. It does not consider different "buoy near" or "buoy far" speeds.
%
% Following the MERMAID defaults:
% *CMDPARKDEPTH takes and returns "depths" in dbar (1 dbar ~ 1 m)
% *CMDPARKDEPTH takes and returns times in min
% *CMDPARKDEPTH takes and returns speeds in dbar/s
%
% Input:
% park_depth        Parking depth [dbar (~m)] (def: 1500)
% dive_duration     Approximate total dive time [min] (def: 12500)
% descent_speed     Approximate descent speed in [mbar/s (~0.01 m/s)] (def: 2.5)*
%                       (NB, 2.5 mbar/s ~ 0.025 m/s ~ 90 m/hr;
%                        or, ~ 40.0 s/m, ~ 1.1 hr/100 m)
% ascent_speed      Approximate descent speed in [mbar/s (~0.01 m/s)] (def: 8)
%                       (NB, 8.0 mbar/s ~ 0.080 m/s ~ 288 m/hr ;
%                        or, ~ 12.5 s/m ~ 0.3 hr/100 m)
% depth_tolerance   Depth tolerance (+-) at parking depth [dbar (~m)] (def: 50)
%
% Output:
% *N/A*             Printout of stage 1 and stage 2 commands formatted for .cmd
%
% *MERMAID float manual 452.000.852 version 00 claims a default descent rate of
%  ~3 mbar/s, though our original .cmd files programmed by OSEAN all added a
%  time buffer to stage 1 that estimated something more like 2.5 mbar/s.
%
% NB, for cleanliness:
% *stage 1 and stage 2 times are rounded up to the nearest 10 min
% *depth tolerances are rounded to the nearest 1 m; parking depth to 10 m
%
% Ex: (standard MERMAID dive: 1500 m, surfacing every ~8 days)
%    CMDPARKDEPTH(1500,  8.41*(24*60))
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Future:
%
% *Missions with more than two stages
% *Missions with differing "buoy near" and "buoy far" speeds

% Defaults.
defval('park_depth', 1500)
defval('dive_duration', 12500)
defval('pressure_tolerance', 50)
defval('descent_speed', 2.5)
defval('ascent_speed', 8)

% Validate inputs.
validateattributes([park_depth, dive_duration, descent_speed, ascent_speed, ...
                    pressure_tolerance], {'double'},  {'positive'})

% The total dive time, ignoring the bypass stage and time required for GPS fixes
% at the surface (both on the order of minutes), is the sum of the time of the
% two stages plus the ascent time:
%
% dive_duration = descent_duration + park_duration + ascent_duration

% Convert descent/ascent speed from mbar/s to dbar/s (= m/s)
descent_speed = descent_speed / 100; % m/s
ascent_speed = ascent_speed / 100; % m/s

% Compute descent/ascent durations given requested parking depth.
descent_duration = park_depth / descent_speed; % s
descent_duration = descent_duration / 60; % min

ascent_duration = park_depth / ascent_speed;
ascent_duration = ascent_duration / 60;

% Compute the stage 2 (acquisition at parking depth) duration.
park_duration = dive_duration - (descent_duration + ascent_duration); % min

% Check sanity.
if park_duration < 0
    error('The requested dive duration is shorter than the time required to descend and ascend')

end

% Define anonymous functions for rounding to nearest ten.
roundup10 = @(xx) ceil(xx/10) * 10;

% The first number in both stages is the stage duration, and the second number
% the total time elapsed since leaving the surface.
stage1_duration = descent_duration;
stage1_duration = roundup10(stage1_duration);
stage1_time_elapsed = stage1_duration;

stage2_duration = park_duration;
stage2_duration = roundup10(stage2_duration);
stage2_time_elapsed = stage1_time_elapsed + stage2_duration;

% Validate rounding did not upset timing.
if ~isequal(stage2_time_elapsed, stage1_time_elapsed+stage2_duration)
    error('Stage 2 time elapsed does not equal Stage1 time elapsed plus stage2 park duration')

end

% Round the depths.
depth_tolerance = ceil(pressure_tolerance);
park_depth = roundup10(park_depth);

% Format the output.
fprintf('stage %idbar (%idbar) %imn (%imn)\n', ...
        park_depth, pressure_tolerance, stage1_duration, stage1_time_elapsed)
fprintf('stage %idbar (%idbar) %imn (%imn)\n', ...
        park_depth, pressure_tolerance, stage2_duration, stage2_time_elapsed)
