function cmap = blueblackredcmap(M)
% cmap = BLUEBLACKREDCMAP(M)
%
% BLUEBLACKREDCMAP returns an M x 3 matrix containing a
% blue-to-black-to-red colormap.  If M is even the colormap is
% asymmetric with one more extreme blue value (see Ex2).
%
% Input:
% M        Number of different colors in the colormap
%              (min. 3, def: 255)
%
% Output:
% cmap     M x 3 colormap that grades from blue to black to red
%
% Ex1:
%    surf(peaks)
%    colormap(BLUEBLACKREDCMAP)
%
% Ex2:
%    BLUEBLACKREDCMAP(3)
%    BLUEBLACKREDCMAP(4)
%    BLUEBLACKREDCMAP(5)
%    BLUEBLACKREDCMAP(6)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 09-Mar-2020, Version 2017b on GLNXA64

% Default.
defval('M', 255)

% Sanity.
if ~isint(M)
    error('M must be an integer')

end
if M < 3
    error('M must must be >= 3')
end


% Main.
N = ceil(M/2);
if mod(M,2) ~= 0
    zero_zero = zeros(1, N);
    zero_one = linspace(0, 1, N);

    % If odd remove the repeated [0 0 0] in the middle.
    r = [zero_zero zero_one(2:end)];
    g = [zero_zero zero_zero(2:end)];
    b = flip(r);

else
    zero_zero = zeros(1, N+1);
    zero_one = linspace(0, 1, N+1);

    % If even remove the repeated [0 0 0] in the middle, and chop off the
    % last extreme red value.
    r = [zero_zero zero_one(2:end-1)];
    g = [zero_zero zero_zero(2:end-1)];
    b = [flip(zero_one) zero_zero(2:end-1)];

end
cmap = [r(:) g(:) b(:)];
