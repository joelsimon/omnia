function fr = fresnelmax(v, f, d)
% fr = FRESNELMAX(v, f, d)
%
% Compute maximum radius of first Fresnel zone.
%
% Input:
% v       Velocity  [m/s]
% f       Frequency [Hz]
% d       Epicentral distance [m]
%
% Output:
% fr      Maximum radius of first Fresnel zone [m]
%
% Ex: 5 Hz T wave recorded at 3000 km
%    v = 1500; f = 5; d = 3e6;
%    fr = FRESNELMAX(v, f, d)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% See fresnelmax_fresneldist.pdf
fr = 1/2*sqrt([v*d]/f);
