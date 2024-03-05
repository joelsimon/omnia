function fr = fresnelradius(r, R, v, f);
% fr = FRESNELRADIUS(r, R, v, f);
%
% Radius of first Fresnel zone as a function of distance from source.
%
% Input:
% r       Distance from source to compute Fresnel radius [m]
% R       Epicentral distance [m]
% v       Velocity  [m]
% f       Frequency [Hz]
%
% Output:
% fr      Radius of first Fresnel zone [m]
%
% Ex1: Maximum Fresnel radius for 5 Hz T wave recorded at 3000 km
%    R = 3e6 ; r = R/2 ; v = 1500; f = 5;
%    fr = FRESNELRADIUS(r, R, v, f)
%
% Ex2: Maximum Fresnel radius for 1 Hz surface wave recorded at 90 degrees
%    R = deg2km(90)*1000 ; r = R/2; v = 3500 ; f = 1;
%    fr = FRESNELRADIUS(r, R, v, f)
%
% Ex3: In-text example from citation
%    r = [10e3 18e3 26e3]; R = 52e3; v = 1500 ; f = 100;
%    fr = FRESNELRADIUS(r, R, v, f)
%
% Citation: Skarsoulis & Cornuelle (2004), JASA, 10.1121/1.1753292.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 04-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Sanity.
if any(r > R)
    error('Requested distance greater than total distance')

end

% Equation (22) from Skarsoulis & Cornuelle (2004).
fr = sqrt([r.*(R-r)*v]/(f*R))';
