function [km,kw,alfa] = kmkw(interp);
% [kmstr,kwstr,alfa] = KMKW(interp)
%
% KWKM returns km, kw, alpha strings formatted for Latex or Tex,
% useful for annotating plots.
%
% Input:
% interp           'latex' or 'tex' (def: 'tex')
%
% Outputs:
% km, kw, alpha    Latex or tex formatted text strings
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 15-Feb-2019, Version 2017b

defval('interp','tex')

switch lower(interp)
  case 'latex'
    km = '$k_\mathrm{m}$';
    kw = '$k_\mathrm{w}$';
    alfa = '$\alpha$';
  case 'tex'
    kw = 'k_w';
    km = 'k_m';
    alfa = '\alpha';
  otherwise
    error(sprintf('unrecognized interpreter'))
end
