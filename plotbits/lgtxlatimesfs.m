function lgtxlatimesfs(lg, tx, fs)
% LGTXLATIMESFS(lg, tx, fs)
%
% LGTXLATIMESFS updates lg and tx outputs of textpatch.m to use Times
% font, with the specified font size, run through the LaTeX
% interpreter.
%
% Input:
% lg, tx      Legend and text handles output by textpatch.m
% fs          Fontsize
%
% See also: textpatch.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 08-Feb-2019, Version 2017b

set(lg, 'FontSize', fs)
set(lg, 'FontName', 'Times')
set(lg, 'Interpreter', 'Latex')

set(tx, 'FontSize', fs)
set(tx, 'FontName', 'Times')
set(tx, 'Interpreter', 'Latex')




