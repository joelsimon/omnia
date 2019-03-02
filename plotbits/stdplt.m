function defs = stdplt
% defs = STDPLT
%
% Returns defs struct with plotting defaults I like.  Useful for
% top-level, standard syntax. Load and adjust locally.
%
% See also: latimes.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Aug-2017, Version 2017b

defs.font.sizeTitle = 24;
defs.font.sizeLabel = 18;
defs.font.sizeBox = 16;
defs.font.name = 'Times';
defs.font.weight = 'Normal';
defs.lineWidth = 1;
defs.color = 'k';
defs.Interpreter = 'latex';
defs.tickLength = [.01 .01];
defs.tickDir = 'out';
