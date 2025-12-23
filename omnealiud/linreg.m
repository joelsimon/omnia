function [r2, p, r2_adj, yfit] = linreg(x, y, n)
% [r2, p, r2_adj, yfit] = LINREG(x, y, n)
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
% r2               Coefficient of determination (1 - SSres/SStot; "R-squared")
% p                Best fit polynomial from polyfit
% r2_adjust        Adjusted R-squared value
%                      (penalizes higher order fits)
% yfit             Fitted curve, evaluated at points in `x`
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 22-Dec-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Default.
defval('n', 1)

% Fit data, calculate residuals, return (adjusted, maybe) R-squared.
x = x(:);
y = y(:);
p = polyfit(x, y, n);

yfit = polyval(p, x);
yresid = y - yfit;

SSres = sum(yresid.^2);
SStot = (length(y)-1) * var(y);

r2 = 1 - SSres/SStot;
if n > 1
    r2_adj = 1 - SSres/SStot * (length(y)-1)/(length(y)-length(p));

else
    r2_adj = NaN;

end
