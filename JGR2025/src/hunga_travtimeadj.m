function [tt_adj, dist_m] = hunga_travtimeadj(kstnm, c, tz)
% [tt_adj, dist_m] = HUNGA_TRAVTIMEADJ(kstnm, c, tz)
%
% Returns time adjusment to be ADDED to theoretical travel time from HTHH to
% station at velocity `c` (for the entire path length) to arrive at "true"
% (adjusted) theoretical travel time, accounting for faster path through rock
% before P-to-T-wave conversion.  P-wave velocity assumed to be 5800 m/s (top
% layer of ak145); T-wave velocity input; P-to-T wave conversion point
% determined by hunga_dist2slope.m
%
%           tt^star = tt + tt_adj
%
% tt^star = "true" (adjusted theoretical travel time)
%      tt = theoretical travel time for T-wave velocity from source to reciever
%  tt_adj = (negative) time difference travel time from source to P-to-T wave
%           conversion point, assuming P wave or T-wave (`c`) velocity.
%
% Input:
% kstnm   Station name
% c       Acoustic velocity [m/s] (def: 1480)
% tz      P-to-T-wave conversion elevation [m] (def: -1350)
%
% Output:
% tt_adj  Travel-time adjustment to be ADDED to theoretical travel time
%            at velocity c [s]
% dist_m  Distance in meters to first occurence of elevation on slope
%
% See also: hunga_dist2slope and hunga_travtimeadj.pdf
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Jul-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('c', 1480);
defval('tz', -1350)

if tz > 0
    error('P-to-T conversion ELEVATION must be negatiave (not a depth)\n')

end

% Conversion point (P-to-T; traveled this distance as a P wave).
dist_m = hunga_dist2slope(kstnm, tz, false);
p_time_s = dist_m / 5800; % ak135 uppper crust

% Compared with (slower) T time.
t_time_s = dist_m / c;

% Travel-time adjustment (adjusts travel time assuming T-wave for full path from
% source to reciever, to one that starts as P wave from source to conversion
% point on slope).
tt_adj = p_time_s - t_time_s;
