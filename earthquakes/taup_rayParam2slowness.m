function p = taup_rayParam2slowness(rayParam)
% p = TAUP_RAYPARAM2SLOWNESS(rapParam)
%
% Convert spherical-Earth "rayParam" output by MatTauP package written by Qin Li
% to flat-Earth ray parameter (horizontal slowness?) as returned by
% terminal-based `taup`, written by H. Philip Crotwell, Thomas J. Owens, and
% Jeroen Ritsema
%
% Input:
% rayParam       .rayParam output by MatTap, e.g., taupTime [s]
%
% Output:
% p              Ray parameter (horizontal slowness) [s/deg]
%
% More details: MatTaup returns a bizarre ".rayParam" in units of s (really it
% is s/m multiplied by the radius of the earth in m).
%
% The ray parameter (eg. 12.2 Dahlen and Tromp) is:
%
%             p = r*sin(i)/v
%
% MatTauP returns this in unis of s (or s/km if you ignore dimension of radius).
%
% Assume P wave incident at 20.45 degrees in ak135 (top layer 5.8 km/s):
% MatTauP -->
% >> tt = taupTime('ak135', 664, 'P', 'deg', 57.889)
%
% >> tt.rayParam
% ans =
% 383.8419
%
% because 6371e3 * sind(20.45) / 5.8e3 ~= 383.8.
%
% taup -->
% $ taup_time -h 664  -ph P -deg 57.889 -mod ak135
%
% Model: ak135
% Distance   Depth   Phase   Travel    Ray Param  Takeoff  Incident  Purist    Purist
%   (deg)     (km)   Name    Time (s)  p (s/deg)   (deg)    (deg)   Distance   Name
% -----------------------------------------------------------------------------------
%    57.89   664.0   P        531.17     6.699     46.59    20.45    57.89   = P
%
% Therefore to convert ray parameter from MatTauP to taup convention we must
% divide by radius of Earth and multiply by number of m in deg.
%
% r = 6371e3;
% p = (rayParam / r) * deg2km(1, r);
%
% See also: phangle
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 02-Apr-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Recursive.
if length(rayParam) > 1
    for i = 1:length(rayParam)
        p(i) = taup_rayParam2slowness(rayParam(i));

    end
    return
end
%% Recursive.

% Leave radius in km so there is no confusion with `deg2km` (could convert all to
% m, but then a deg2km(1, r) call with r in meters is confusing because it is
% "degrees to kilometers" but r returning meters).
r = 6371;
p = (rayParam / r) * deg2km(1, r);
