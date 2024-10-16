function Lp = spl(p, p0)
% Lp = SPL(p, p0)
%
% Sound pressure level in dB relative to reference pressure:
%    Lp = 20*log10(p/p0)
%
% Input:
% p       RMS sound pressure [Pa]
% p0      Reference pressure
%             1:  1 uPa (in water; def)
%             2: 20 uPa (in air)
%
% Output:
% Lp      Sound pressure level [dB]
%
% See: Guide for the Use of the International System of Units (SI)
%      NIST Special Publication 811 2008 Edition
%      Ambler Thompson and Barry N. Taylor
%
% Ex1: MERMAID earthquake (RMS = 2 Pa) at hydrophone (in water)
%    LP = SPL(2, 1)
%
% Ex2: Vuvuzela (RMS = 20 Pa) at 1 m (in air)
%    Lp = SPL(20, 2)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('p0', 1)

uPa = 1e-6;
switch p0
  case 1
    p0 = 1*uPa;

  case 2
    p0 = 20*uPa;

  otherwise
    error('`p0` must be one of `1` or `2`')

end

Lp = 20*log10(p/p0);
