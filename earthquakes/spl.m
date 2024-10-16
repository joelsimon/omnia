function Lp = spl(P, P0)
% Lp = SPL(P, P0)
%
% Sound pressure level in dB relative to reference pressure.
%
% Input:
% P       Sound pressure (Pa)
% P0      Reference pressure
%             1:  1 uPa (underwater; def)
%             2: 20 uPa (in air)
%
% See: Guide for the Use of the International System of Units (SI)
%      NIST Special Publication 811 2008 Edition
%      Ambler Thompson and Barry N. Taylor
%
% Ex1: Typical MERMAID earthquake, 2 Pa at hydrophone
%    LP = SPL(2, 1)
%
% Ex2: vuvuzela (20 Pa) at 1 m, in air
%    Lp = SPL(20, 2)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Oct-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('P0', 1)

uPa = 1e-6;
switch P0
  case 1
    P0 = 1*uPa;

  case 2
    P0 = 20*uPa;

  otherwise
    error('`P0` must be one of `1` or `2`')

end

Lp = 20*log10(P/P0);
