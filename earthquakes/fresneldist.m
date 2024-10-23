function d = fresneldist(fr, v, f)
% d = fresneldist(fr, v, f)
%
% Compute epicentral distance given maximum radius of first Fresnel zone.
%
% Input:
% fr      Maximum radius of first Fresnel zone [m]
% v       Velocity  [m/s]
% f       Frequency [Hz]
%
% Output:
% d       Epicentral distance [m]
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% See fresnelmax_fresneldist.pdf
d = (4*fr^2*f)/v;
