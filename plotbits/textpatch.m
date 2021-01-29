function [lg, tx, ha2] = textpatch(ha, loc, str, fsize, fname, LaTeX, varargin)
% [lg, tx, ha2] = TEXTPATCH(ha, loc, str, fsize, fname, LaTeX, ['option',value...])
%
% TEXTPATCH places a text patch in the specific location in an axis,
% much like legend.m
%
% Input:
% ha                 Axes handle (def: gca)
% loc                Legend location (def: 'NorthWest')
% str                The string to be printed (def: 'Hello\nWorld!)
% fsize              FontSize (def: 12)
% fname              FontName (def: 'Times')
% LaTeX              logical true for LaTeX interpreter (def: true)
% ['option', value]  Name, value pairs for legend.m
%                        Warning: this may not work
%                        and/or have unexpected results.
% Output:
% lg                 Legend handle
% tx                 Text handle
% ha2                New axes where lg and tx live
%
% TEXTPATCH generates a new axis with and uses MATLAB's builtin
% legend.m to generate a smart text patch within the new axes.  I have
% to use [a,b] = legend(...) syntax which is not recommended and leads
% to spurious results.  Note that latimes.m and axesfs.m do not update
% the outputs here correctly.  Must update tx.FontName and tx.FontSize
% directly.  Also, lg.Position(3) seems to have a lower limit so I
% cannot shrink the width of the legend patch to get it tighter to the
% string.
%
% Ex: (Move textpatch location around figure window)
%    x = linspace(0, 2*pi, 1e3);
%    y = sin(x);
%    figure; ha = gca;
%    plot(x,y); axis tight
%    lg = textpatch(ha, 'NorthWest', 'A Sin Wave'); pause(1);
%    lg.Location = 'North'; pause(1);
%    lg.Location = 'NorthEast'; pause(1);
%    lg.Location = 'SouthEast'; pause(1);
%    lg.Location = 'South'; pause(1);
%    lg.Location = 'SouthWest'; pause(1);
%
% See also: tack2corner.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 02-Jul-2018, Version 2017b

% Suppress warnings.
warn_state = warning;
warning('off', 'all')

%% N.B.: This is very finicky. Do not adjust order of code below.

% Defaults.
defval('ha', gca)
defval('loc', 'NorthWest')
defval('str', sprintf('Hello\nWorld!'))
defval('LaTeX', true)
defval('fname', 'Times')
defval('fsize', 12)

% Record current 'hold' state so that it's returned in same state
% after function. Turn on if necessary.
hstate = ishold(ha);
if ~hstate
    hold(ha, 'on')

end

% Decide on an interpreter.
if LaTeX
    interpreter = 'LaTeX';

else
    interpreter = 'Tex';

end

% Only one legend per axis is allowed, thus create a new, clear axis
% in the same location as requested.
ha2 = axes;

% Plot a null value.
pl = plot(ha2, NaN, NaN, '.');

% Make overlain axes transparent.
ha2.Position = ha.Position;
uistack(ha2, 'top')
ha2.Visible = 'off';

% Add legend for null value using requested string and options.  Note
% that with two outputs legend acts oddly and varargin doesn't always
% work as expected.  Hence I edit font size and interpreter later.
[lg, lgobj] = legend(ha2, pl, str, 'Location', loc, varargin{:});

% Delete the marker and (nonexistent) line in the legend box.
delete(lgobj(2:3))

% lgobj(1) is the text handle.
tx = lgobj(1);

% Set text in middle of lg patch.
tx.Position(1) = 0.5;
tx.HorizontalAlignment = 'Center';

% Update with font preferences.
lg.FontSize = fsize;
lg.FontName = fname;
lg.Interpreter = interpreter;

tx.FontSize = fsize;
tx.FontName = fname;
tx.Interpreter = interpreter;

% Finally, adjust the color.  Leave this here.  If this line is moved
% up the code does not work properly.
ha2.Color = 'none';

% Turn hold 'off' it function entered that way.
if ~hstate
    hold(ha, 'off')

end

% Restore entry warning state.
warning(warn_state)
