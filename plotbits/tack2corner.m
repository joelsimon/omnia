function tack2corner(ha1, ha2, co)
% TACK2CORNER(ha1, ha2, co)
%
% TACK2CORNER places a handle (e.g., patch or legend) into the
% corner of another handle (e.g., an axes).
%
% Input:
% ha1      The handle to remain stationary
% ha2      The handle to be moved
% co       The corner of ha1 in which to place ha2, one of
%          'ul' (or 'NorthWest')
%          'ur' (or 'NorthEast')
%          'lr' (or 'SouthEast')
%          'll' (or 'SouthWest')
%
% Ex: Move legend clockwise around axes
%    figure; plot(1:10);
%    ha1 = gca;
%    ha2 = legend('A linear line');
%    tack2corner(ha1, ha2, 'ul'); pause(1)
%    tack2corner(ha1, ha2, 'ur'); pause(1)
%    tack2corner(ha1, ha2, 'lr'); pause(1)
%    tack2corner(ha1, ha2, 'll'); pause(1)
%    
% See also: axpos.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 07-Feb-2019, Version 2017b

% Nab the relevant corner positions.
pos = axpos(ha1);

% Move the ha2 to the requested corner of ha1.
switch lower(co)
  case {'ul', 'northwest'}
    ha2.Position(1) = pos.ul(1);
    ha2.Position(2) = pos.ul(2) - ha2.Position(4);

  case{'ur', 'northeast'}
    ha2.Position(1) = pos.ur(1) - ha2.Position(3);
    ha2.Position(2) = pos.ur(2) - ha2.Position(4);

  case{'lr', 'southeast'}
    ha2.Position(1) = pos.lr(1) - ha2.Position(3);
    ha2.Position(2) = pos.lr(2); 
    
  case {'ll', 'southwest'}
    ha2.Position(1:2) = pos.ll;

  otherwise
    error('Invalid corner specification')

end
