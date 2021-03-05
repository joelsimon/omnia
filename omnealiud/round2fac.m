function val = round2fac(val, fac, updown)
% val = ROUND2FAC(val, fac, updown)
%
% Round a value up or down to the nearest multiple of a factor (or 0).
%
% Input:
% val      Value to be rounded
% fac      Rounding factor
% updown   '': Use MATLAB's `round` (default)
%          'up': Use MATLAB's `ceil
%          'down': Use MATLAB's `floor`
%
% Ex:
%    ROUND2FAC(870, 100)
%    ROUND2FAC(870, 100, 'up')
%    ROUND2FAC(870, 100, 'down')
%    ROUND2FAC(10, 11)
%    ROUND2FAC(10, 11, 'up')
%    ROUND2FAC(10, 11, 'down')
%    ROUND2FAC(28, 14.5)
%    ROUND2FAC(28, 14.5, 'up')
%    ROUND2FAC(28, 14.5, 'down')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('updown', '')

if fac < 0
    error('Input ''fac'' must be positive')

end

switch lower(updown)
  case ''
    rounder = @round;

  case 'up'
    rounder = @ceil;

  case 'down'
    rounder = @floor;

  otherwise
    error('Input ''updown'' must be one of ''up'' or ''down''')

end

val = rounder(val/fac)*fac;
