function latimes2(fig, degs)
% LATIMES2(fig, degs)
%
% Change all text, ticklabel, legend, and axes fonts of input figure(s) to
% 'Times', but keep interpreter default 'tex' (as opposed to 'LaTeX').
%
% Input:
% fig         Figure object handle (def: gaf)
% degs        (will erorr: need to update)
%             Figure includes text degree ('^{\circ}') symbols (def: false)
%
% Output:
% All fonts set to 'Times' and Interpreters 'Latex' where
% applicable. N.B. axes don't have an interpreter field.
%
% Ex1:
%    plot(randn(1,100))
%    title('\alpha, \beta, \gamma')
%    LATIMES2(gcf)
%
% See also: latimes
% 
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 15-Feb-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default to use current figure(s).
defval('fig', gaf)
defval('degs', false)

% Sanity.
if ~all(isgraphics(fig,'Figure'))
    error('Pass figure handle(s) only.')
end

% Main.
for i = 1:length(fig)
    tx = findall(fig(i), 'type', 'text');
    ax = findall(fig(i), 'type', 'axes');
    lg = findall(fig(i), 'type', 'legend');
    cb = findall(fig(i), 'type', 'colorbar');

    set([tx(:) ;  lg(:)], 'Interpreter', 'tex', 'FontName', 'Times');
    set([ax(:) ;  cb(:)], 'TickLabelInterpreter', 'tex', 'FontName', 'Times')

end
