function xax = xaxis(lx, delta, pt0)
% xax = XAXIS(lx, delta, pt0)
%
% Given length of signal (in samples) and sampling interval 
% (not frequency) in seconds, suggests x-axis for plotting. 
% Sets first sample at 0 seconds by default.
%
% N.B. Set pt0 = 1, fs = 1 to plot in terms of samples, starting
% with the first sample.
%
% E.g., delta = 1 and pt0 = 1 second
% Sample:    1     2     3     4     5     6     7     8     9    10
%   Time:    1     2     3     4     5     6     7     8     9    10
%
% E.g., delta = 0.05 and pt0 = 0 seconds
% Sample:    1     2     3     4     5     6     7     8     9    10
%   Time: 0.00  0.05  0.10  0.15  0.20  0.25  0.30  0.35  0.40  0.45
%
% E.g., delta = 0.05 and pt0 = 25 seconds
% Sample:    1      2      3      4      5      6      7       8  
%   Time: 25.0  25.05  25.10  25.15  25.20  25.25  25.30   25.35  
%
% Inputs: 
% lx        Length of time series, in samples
% delta     Sampling interval in seconds
%               (e.g, h.DELTA in SAC header)
% pt0       Time assigned to the first sample of x, in seconds
%              (e.g., h.B in SAC header)
%
% Output:
% xax          x-axis in seconds
%
% Ex1: Plot in samples and seconds starting at both 0 and 30 s
%  lx    = 1000;        
%  sig   = normcpgen(lx, 500, 10);
%  freq  = 20;          
%  delta = 1/freq;      
%  pt0   = 0;           
%  pt30  = 30;          
%  xax0  = XAXIS(lx, delta,pt0);
%  xax30 = XAXIS(lx, delta,pt30);
%  ha1 = subplot(3, 1, 1); ha2 = subplot(3, 1, 2);
%  ha3 = subplot(3, 1, 3);
%  plot(ha1, sig);      title(ha1, 'Plotted in samples')
%  plot(ha2, xax0, sig);  title(ha2, 'Plotted in seconds from 0')
%  plot(ha3, xax30, sig); title(ha3, 'Plotted in seconds from 30')
%  shg
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 25-Nov-2018, Version 2017b

% Defaults.
defval('pt0', 0)

% Sanity.
if nargin < 2
    error('Must supply first two (2) arguments.'); 
end

if any(~isnumeric([lx delta pt0]))
    error('All inputs must be numeric.')
end

if ~isint(lx)
    error('First input ''lx'' is signal length in samples; must be integer.')
end

if length(delta)~=1 || delta<=0
    error('Sampling interval ''delta'' must be single number greater than 0.')
end

if length(pt0)~=1
    error('Third input ''pt0'' can only be single number.')
end

% Main.
xax = (delta*[0:lx-1]) + pt0;
xax = xax(:);
