function col = porange
% col = PORANGE
%
% Return the RGB color space of "Princeton Orange" (Pantone (PMS) 158).
%
% Ex: axes('Color', PORANGE)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 22-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% From: https://communications.princeton.edu/guides-tools/logo-graphic-identity
% “Princeton Orange” is defined as Pantone (PMS) 158"

% From: https://www.pantone.com/color-finder/158-C
rgb = [232 119 34];

col = rgb / 255;
