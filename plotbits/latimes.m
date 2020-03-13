function latimes(fig, degs)
% LATIMES(fig, degs)
%
% Change all text, ticklabel, legend, and axes fonts of input
% figure(s) to 'Times', and set the interpreter to 'Latex', where
% applicable.
%
% Input:
% fig         Figure object handle (def: gaf)
% degs        Figure includes text degree ('^{\circ}') symbols (def: false)
%
% Output:
% All fonts set to 'Times' and Interpreters 'Latex' where
% applicable. N.B. axes don't have an interpreter field.
%
% Ex:
%    plot(randn(1,100))
%    title('$\alpha\,, beta\,, \gamma$')
%    LATIMES(gcf)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Mar-2020, Version 2017b on MACI64

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

    % This should work, but does not for unknown reasons.
    %findobj(gcf, 'type', 'text', '-depth', inf)

    if degs
        % Put dollar signs ('$') around degrees (^{\circ}) so they compile
        % correctly in LaTeX.
        for j = 1:length(tx)
            tx(j).String = strrep(tx(j).String, '^{\circ}', '$^{\circ}$');

        end
    end
    set([tx(:) ;  lg(:)], 'Interpreter', 'Latex', 'FontName', 'Times');
    set([ax(:) ;  cb(:)], 'TickLabelInterpreter', 'Latex', 'FontName', 'Times')

end
