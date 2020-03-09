function [r2,p,r2_adj] = linreg(x,y,n)
% [r2,p,r2_adj] = LINREG(x,y,n)
%
% Performs linear regression and computes R-squared value in a
% least-squares sense. Code follows MATLAB's help doc, 'Linear
% Regression'.
%
% Input:
% x                Explanatory variable
% y                Observed data
% n                Order of polynomial fit (def: 1)
%
% Output:
% r2               R-squared value
% p                Best fit polynomial from polyfit
% r2_adjust        Adjusted R-squared value
%                      (penalizes higher order fits)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Jan-2016, Version 2017b

% Default.
defval('n',1)

% Fit data, calculate residuals, return (adjusted, maybe) R-squared.
p = polyfit(x,y,n);

yfit = polyval(p,x);
yresid = y - yfit;

SSres = sum(yresid.^2);
SStot = (length(y)-1) * var(y);

r2 = 1 - SSres/SStot;
if n > 1
    r2_adj = 1 - SSres/SStot * (length(y)-1)/(length(y)-length(p));

else
    r2_adj = NaN;

end
