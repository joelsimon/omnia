function [Lp2, Lp1] = spldist(r2, p, p0, r1, propto)
% [Lp2, Lp1] = SPLDIST(r2, p, p0, r1, propto)
%
% Sound pressure level in dB at r2 given RMS sound pressure at r1.
%
% Input:
% r2      Distance to compute adjust sound pressure Lp2 [m]
% p       RMS sound pressure at r1 [Pa]
% p0      Reference pressure
%             1:  1 uPa (in water; def)
%             2: 20 uPa (in air)
% r1      Distance at which RMS sound pressure was recorded [m]
% propto  Distance-pressure geometrical spreading proportionality -->
%             1: spherical spreading (body wave); p propto 1/r
%             2: cylindrical spreading (t wave); p propto 1/sqrt(r) (def)
%
% Output:
% Lp2      Adjusted sound pressure level at r2 [dB]
% Lp1      Measured sound pressure level at r1 [dB]
%
% See: Guide for the Use of the International System of Units (SI)
%      NIST Special Publication 811 2008 Edition
%      Ambler Thompson and Barry N. Taylor
%
% Ex: RMS=2 Pa measured at 100 km, adjusted to 500, 1000, 1500 km
%    r2 = [500:500:1500]*1e3; p = 2; p0 = 1; r1 = 100e3; propto = 2;
%    [Lp2, Lp1] = SPLDIST(r2, p, p0, r1, propto)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Nov-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

Lp1 = spl(p, p0);
switch propto
  case 1
    Lp2 = Lp1 + 20*log10(r1./r2);

  case 2
    Lp2 = Lp1 + 20*log10(sqrt(r1./r2));

end
