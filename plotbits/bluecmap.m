function cmap = bluecmap(M, sing)
% cmap = BLUECMAP(M, sing)
%
% BLUECMAP returns an M x 3 matrix containing a white-to-blue
% (low to high intensity) colormap.
%
% Input:
% M        Number of different colors in the colormap
%              (min. 2, def: 64)
% sing     true be serenaded, thrice (def: false)
%
% Output:
% cmap     M x 3 colormap that grades from white to blue
%
% Ex1:
%    surf(peaks)
%    colormap(BLUECMAP(64, true))
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Mar-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('M', 64)
defval('sing', false)

% Sanity.
if ~isint(M)
    error('M must be an integer')

end
if M < 2
    error('M must must be >= 2')
end

% Main.
r = linspace(1, 0, M);
g = r;
b = ones(size(r));
cmap = [r(:) g(:) b(:)];

if sing
    i = 0;
    while i < 3
        fprintf('I''m blue\nDa ba dee da ba di\n')
        pause(0.75)
        i = i + 1;

    end
end
