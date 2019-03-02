function [ml, mr, sl, sr, vl, vr] = cumstats(x, bias)
% [ml,mr,sl,sr,vl,vr] = CUMSTATS(x, bias)
%
% Cumulative Statistics.  
%
% Computes cumulative sample statistics starting at left (top), and
% right (bottom), of an input time series. Left statistics are the
% intuitive statistics we are used to; the first sample is 1 and the
% last sample is N. Right statistics are computed on a flipped time
% series; the first sample is N and the last sample is 1. Useful for
% cpest.m, which compares the left x(1:k), and right variances
% x(k+1:N), for k = [1,..,N], at every index, k, of a time series,
% x(k). Option to return biased (normalized by N), or unbiased
% variance estimates (using Bessel's correction of (N-1)).
%
% Input:
% x                Time series, accepts 1D cells (e.g., 'd' from wt.m) 
% bias*            true to return biased estimate of sample variance (1/N) (def: false)
%                  false to return unbiased estimate of the sample variance (1/N-1)
%
% Outputs:
% ml, mr           Cumulative sample mean running from left (top), right (bottom)
% sl, sr**         Square root of the cumulative sample variance from left, right
% vl, vr           Cumulative sample variance from left, right
%     
%
% * bias = false: var(k) = 1/(length(k)-1)*sum((k-mean(k)).^2)
%   bias = true: var(k) = 1/length(k)*sum((k-mean(k)).^2)
%
% ** In either biased or unbiased case, the "standard deviations"
% returned are simply the square root of these estimated variances.
% And even in the case of an unbiased estimate of the variance, the
% standard deviation is ALWAYS biased (it is an underestimate, see
% Jensen's inequality). Ergo, I won't call sl, sr, estimates of the
% sample standard deviations in the case of a BIASED estimate of the
% variance. In that case it is the square root of the biased estimate
% of the sample variance. YMMV.
%
% The pattern for LEFT statistics, at index k, is:
%       ml(k)  == mean(x(1:k)).
% E.g., ml(12) == mean(x(1:12)).
%
% The pattern for RIGHT statistics, at index, k is:
%        mr(k) == mean(x(end:-1:end-k+1)), which is equivalent to,
%              == mean(x(end-k+1:end).
% E.g., mr(12) == mean(x(end-11:end)).
%
% Ex: CUMSTATS('demo')
%
% See also: cpvar.m, cpest.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 24-Jan-2019, Version 2017b

%% Recursive.

% Check if demo requested. If so, run demo and exit.
if ischar(x)
    demo
    return
end

% Default to return unbiased estimate of sample the variance standard deviation.
defval('bias', false)

% This just breaks up cell (if that's what's supplied) and reruns cumstats (below).
if iscell(x)
    for i = 1:length(x)
        [ml{i}, mr{i}, sl{i}, sr{i}, vl{i}, vr{i}] = cumstats(x{i}, bias);
    end

else
    %% Main.
    % Preprocessing to avoid dim mismatch and set +-Inf to NaN.
    x = x(:);
    fx = flip(x);
    [x, idx] = unzipnan(x);
    [fx, fidx] = unzipnan(fx); 
    lx = length(x); % == length(fx)

    % Means.
    ml = cumsum(x) ./ [1:lx]';
    mr = cumsum(fx) ./ [1:lx]';

    % N.B: no option to detrend before taking variance. Removing the mean
    % from the time series has no effect (var(x) == var(x -
    % mean(x))). May want to include higher order stats (linear trends
    % etc.) in future?
    
    % Variances.
    switch bias
      case false
        % Return the UNBIASED estimate, normalized by 1/(N-1).
        vl = (cumsum(x.^2) - [1:lx]'.*ml.^2) ./ [0:lx-1]';
        vr = (cumsum(fx.^2) - [1:lx]'.*mr.^2) ./ [0:lx - 1]';
        
      case true
        % Return the BIASED estimate, normalized by 1/N.        
        vl = (cumsum(x.^2) - [1:lx]'.*ml.^2) ./ [1:lx]';
        vr = (cumsum(fx.^2) - [1:lx]'.*mr.^2) ./ [1:lx]';

      otherwise
        error('Supply either logical true or false for ''bias'' input argument.')
    end
        
    % Standard deviations.
    sl = sqrt(vl);
    sr = sqrt(vr);
    %% End Main.

    % (maybe) Slide NaNs back in proper index (stripped before calculations).
    ml = zipnan(ml, idx);
    sl = zipnan(sl, idx);
    vl = zipnan(vl, idx);

    % Reversed nan indexing on flipped series.
    mr = zipnan(mr, fidx);
    sr = zipnan(sr, fidx);
    vr = zipnan(vr, fidx);

    % Handle numerical error (which should be on the order of 1x10^-15) by
    % setting negative standard deviations and variances to zero.
    if sl < 0
        sl = 0;

    end
    if sr < 0
        sr = 0;

    end
    if vl < 0
        vl = 0;

    end
    if vr < 0
        vr = 0;

    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function demo
   % Generate random signal
   x = cpgen(1000, 500, 'norm', {0 1}, 'norm', {2 4});
   % Collect statistics
   [ml, mr, sl, sr, vl, vr] = cumstats(x);
   % Put everything on one plot
   [~,ha] = krijetem(subnum(4,1));
   % Top plot, 'x' the signal
   axes(ha(1))
   plot(x);
   title('The signal')
   % Second plot, mean from right / left
   axes(ha(2))
   plot(ml, 'b')
   hold on
   plot(mr, 'r')
   hold off
   title('Cumulative mean from left (blue) and right (red)')
   % Third plot, the standard deviation from left / right
   axes(ha(3))
   plot(sl, 'b')
   hold on
   plot(sr, 'r')
   hold off
   title('Cumulative std. from left (blue) and right (red)')
   % Fourth plot, the cumulative variance from left / right
   axes(ha(4))
   plot(vl, 'b')
   hold on
   plot(vr, 'r')
   hold off
   title('Cumulative var. from left (blue) and right (red)')

