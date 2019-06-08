function str = normstrcp(p1,p2,bp,precision,func,eqs)
% str = NORMSTRCP(p1,p2,bp,precision,func,eqs)
%
% Calls normstr.m twice and suggests title given input parameters and
% changepoint.  
%
% Input:
% p1,2             Cell of {mu sigma} for both distributions
% bp               Sample changepoint (index where distribution shifts)
% precision        sprintf precision for intstr.m (def: 1)
% func             String of function prefix (e.g., 'x(k)') (def: f(x))
%                      (if 'none' will not print function prefix)
% eqs              true for equals sign inside  \mathcal{N} (def: true)
%                      (false generates more compact string)
% Output:
% str              LaTeX-formatted string
%
% Ex1: (defaults)
%    subplot(3,1,1)
%    str = NORMSTRCP({0 2},{1.4 2.78},500,1);
%    title(str,'Interpreter','latex');
%
% Ex2: ('x(k)' instead of 'f(x)' prefix)
%    subplot(3,1,2)
%    str = NORMSTRCP({0 2},{1.4 2.78},500,1,'x(k)',true);
%    title(str,'Interpreter','latex');
%
% Ex3: (no function prefix)
%    subplot(3,1,3)
%    str = NORMSTRCP({0 2},{1.4 2.78},500,1,'none',true);
%    title(str,'Interpreter','latex');
%
% See also: normstr.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 20-Jul-2017, Version 2017b

% Defaults.
defval('precision',1)
defval('func','f(x)')
defval('eqs',true)

% Format it.
normstr1 = normstr(p1{1},p1{2},precision,eqs);
normstr2 = normstr(p2{1},p2{2},precision,eqs);
if strcmp(lower(func),'none')
    str = sprintf('$%s$~to~$%s$ at sample %i',normstr1,normstr2,bp);
else
    str = sprintf('$%s\\sim%s$~to~$%s$ at sample %i',func,normstr1,normstr2,bp);
end
