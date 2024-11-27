function ph = c2ph(c, unit)
% ph = C2PH(c, unit)
%
% Convert a phase velocity (e.g., 1483 m/s) to a TauP phase name
% (e.g., '1.483kmps') with meter precision.
%
% Input:
% c       Velocity in either m/s or km/s
% unit    Either 'm/s' or 'km/'s
%
% Output:
% ph      TauP 'kmps' phase name with meter precision
%
% Ex:
%    C2PH(1483, 'm/s')
%    C2PH(1.483, 'km/s')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Nov-2024, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

switch unit
  case 'm/s'
    c = c/1e3;

  case 'km/s'
    % pass

  otherwise
      error('`unit` must be one of ''m/s'' or ''km/s')

end
ph = sprintf('%.3fkmps', c);
