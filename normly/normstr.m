function str = normstr(mu,sigma,precision,eqs)
% str = NORMSTR(mu,sigma,precision,eqs)
%
% Suggests a LaTeX-formatted string for a normal distribution.  Must
% wrap output string in '$' for plotting. Note: the input is the
% standard deviation; the output string quotes the variance.  Default
% returns more compact Norm(mu,sigma^2), not
% Norm('mu'=mu,'sigma^2'=sigma^2) string. Use eqs = true for later.
%
% Input:
% mu,sigma         Mean and standard deviation 
% precision        sprintf precision for intstr.m (def: 1)
% eqs              true for equals sign inside  \mathcal{N} (def: true)
%
% Output:
% str              LaTeX-formatted string
%
% Ex:
%    figure;
%    str1 = NORMSTR(0,2);
%    str2 = NORMSTR(1.4,2.78,2);
%    title(sprintf('$f(x)\\sim%s$~to~$%s$ at sample 500',str1,str2), ...
%          'Interpreter','latex');
%
% See also: normstrcp.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 20-Jul-2017, Version 2017b

% Default.
defval('precision',1)
defval('eqs',true)

% Format it.
mustr = intstr(mu,precision);
varstr = intstr(sigma^2,precision);
if eqs
    str = sprintf('\\mathcal{N}(\\mu{=}%s,\\sigma^2{=}%s)',mustr,varstr);
else
    str = sprintf('\\mathcal{N}(%s,%s)',mustr,varstr);
end
