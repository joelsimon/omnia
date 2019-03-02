function [xl,xr,xl_idx,xr_idx] = contiguous(x,idx,direc)
% [xl,xr,xl_idx,xr_idx] = CONTIGUOUS(x,idx,direc)
%
% CONTIGUOUS returns the limits of integer contiguity for an x-axis.
% Breaks with NaNs/Infs.
%
% More verbose: given a series of monotically increasing (by 1) x
% values (e.g., an x-axis), returns the values and indices of x,
% looking forward/backward from idx to the limit where contiguity is
% broken. If idx (an index/offset into x) is specified it first splits
% the time series into forward/backward chunks and performs the test
% starting from idx.  If idx is not specifid it starts at x(1).  Used
% in all waterbar/alpha codes where 'restrikt' is true.  Forward means
% increasing index, which I call the 'rhs' for right (e.g., x(1:end)),
% and backward means decreasing indices (x(end:-1:1)) which I call
% 'lhs' for left.
%
% Inputs:
% x           1D array of monotonically increasing x values
% idx         Index into x to start search forward/backwards (def: 1)
% direc       Direction to search starting at idx ('rhs','lhs','both')
%                 (def: 'rhs')
%
% Outputs:
% xl/r        Left/right VALUES of x where contiguity maintained
% xl/xr_idx   Left/right INDICES of x where x = xl/xr
%
% Most useful for waterlvlalpha.m(->waterlvlv.m)/waterbar.m where,
% ('undwerater')/'withinbar' are the x values whose corresponding
% values fall within the specifications.  We seek the contiguous
% x-values whos y-values satisfy some condition.
%
% Ex: Given x below, find where contiguity is broken looking
% forward and backward from index 4 (where x = -3) -- 
%
%     x = [-7 -6 -4 -3 -2 -1 0 1 2 3 5 6];
%     [xl,xr] = CONTIGUOUS(x,4,'both');
%     >> xl = -4, xr = 4, xl_idx = 3, xr_idx = 10
% 
% See also: waterbar.m, waterlvlalpha.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 19-Jun-2018, Version 2017b

% Defaults.
defval('idx',1)
defval('direc','rhs')

% Sanity checks, x must be increasing (think of x axis); real.
x = x(:);
assert(all(isfinite(x) > 0),['x must be real (no NaN; Inf). Use ' ...
                    'unzipNaN.m preprocessing if required.'])
assert(all(diff(x) > 0),'x values must be monotically increasing')

% Return at least staring indices and values, to be updated maybe.
xl_idx = idx;
xr_idx = idx;
xl = x(idx);
xr = x(idx);

% Function switch.
switch lower(direc)
  case {'lhs','left','l'}
    [xl,xl_idx] = goleft(x,idx);
  case {'rhs','right','r'}
    [xr,xr_idx] = goright(x,idx);
  case 'both'
    [xl,xl_idx] = goleft(x,idx);
    [xr,xr_idx] = goright(x,idx);
  otherwise
    error('don''t recognize ''direc'' input')
end

% Find left index.
function [xl,xl_idx] = goleft(x,idx)
    % The x segment split at xval of interest into its left chunk.
    actual_lhs = flip(x(1:idx));
    % And compare vs perfectly contiguous segments
    perf_lhs = [x(idx):-1:x(1)]';
    diff_lhs = actual_lhs - perf_lhs(1:length(actual_lhs));
      % Find lhs index.
    if diff_lhs(1) ~= 0 
        % No contiguous points; return xval only.
        xl_idx = idx;
    elseif all(diff_lhs == 0)
        % All points contiguous; return first index of 'x'.
        xl_idx = 1;
    else
        % Else subtract the first index where difference is not zero to
        % starting index.
        xl_idx = idx  - find(diff_lhs~=0,1) + 2; %** Minus/plus 2, see note.
    end
    xl = x(xl_idx);

% Find right index. See comments above. Symmetric functions.
function [xr,xr_idx] = goright(x,idx)
    actual_rhs = x(idx:end);
    perf_rhs = [x(idx):x(end)]';
    diff_rhs = actual_rhs - perf_rhs(1:length(actual_rhs));
    if diff_rhs(1) ~= 0 
        xr_idx = idx;
    elseif all(diff_rhs == 0)
        xr_idx = length(x);
    else
        xr_idx = idx + find(diff_rhs~=0,1) - 2;
    end
    xr = x(xr_idx);

% ** Minus/plus 2:
%
% 1 comes from the find -- find gets first index of nonzero. We want
% the last index of zero so subtract 1.
%
% 2 comes from the fact that when you add indices you have to count
% the first index. E.g., 250+19 = 269; but length(250:269) = 20.  So
% we have to take into account the first x index we count from.
