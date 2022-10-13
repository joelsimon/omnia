function r = fresnelmax(v, f, d)
% r = FRESNELMAX(v, f, d)
%
% Compute maximum radius of first Fresnel zone.
%
% Input:
% v       Velocity  [m]
% f       Frequency [Hz]
% d       Epicentral distance [m]
%
% Output:
% r       Maximum radius of first Fresnel zone [m]
%
% Ex: 5 Hz T wave recorded at 3000 km
%    v = 1500; f = 5; d = 3e6;
%    r = FRESNELMAX(v, f, d)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Oct-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

r = 1/2*sqrt(v/f*d);
