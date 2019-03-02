function wttime = wtxaxis(dbe, lx, DELTA, pt0, cps)
% wttime = WTXAXIS(dbe, lx, DELTA, pt0, cps) 
%
% WTXAXIS maps abe and dbe from wtspy.m to a time axis. Returns
% bracketed TIME INTERVAL IN SECONDS or SAMPLE INTERVAL [start end]
% that details see in the original time series.
%
% Recall a/dbe are bracketed SAMPLE INTERVALS [start end]. They are
% the projection of the sample span of every approx./detail from the
% wavelet to the time domain. E.g., detail{1}(1) is only one detail,
% though it may project onto 40 samples in the original time series if
% the wavelet has a large cone of influence (is a wide basis). If the
% sampling frequency is 5 Hz (DELTA = 0.2), then that detail 'sees' 8
% seconds in the original time series.
%
% Set DELTA = 1, pt0 = 1 to stay in sample space.
%
% Inputs:
% dbe          Detail and/or approx. influence intervals
%                  calculated from wtspy.m
% lx           Length of original time series to which dbe maps
% DELTA        Sampling interval in seconds (use 1 to stay in samples)
% pt0          Time shift in seconds of first point (def: 0)           
% cps          Changepoint indices returned from cpest.m (optional)*
%
% Output:
% wttime       Time each approx/detail maps to in original time series
%
% * If supplied will only calculate the time interval seen by those
% specific changepoint dbe indices. Will not return entire time x-axis.
%
% For the following examples first run:
%    x = cpgen(1000, 678);
%    [a, abe, ~, d, dbe] = ...
%         wtrmedge('time-scale', x, 'CDF', [2 4], 5, 3, 0, true);
%    detail_cps = cpest(d);
%
% Ex1: Complete TIME X-Axis starting at 0 s offset with 5 Hz sampling frequency
%     detail_times = WTXAXIS(dbe, length(x), 1/5, 0)
% 
% Ex2: TIME INTERVAL, starting at 0 s, of detail changepoints estimated from cpest.m
%      changepoint_times = WTXAXIS(dbe, length(x), 1/5, 0, detail_cps)
%
% Ex3: SAMPLES, starting at sample 1, of detail changepoints estimated from cpest.m
%      changepoint_samples = WTXAXIS(dbe, length(x), 1, 1,detail_cps)
%      %...essentially returning a dbe index as dbe already in samples
%      dbe{1}(detail_cps(1),:) == changepoint_samples{1}'
% 
% Ex4: Ex1, but also considering approximation (abe)
%    detail_approx_times = WTXAXIS([dbe abe], length(x), 1/5, 0)
%
% See also: wtspy.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Jan-2018, Version 2017b

% Default.
defval('pt0', 0)

% Error catching.
if nargin < 3
    error('Must supply at least first three (3) inputs.')
end
if ~iscell(dbe)
    error('First input must be cell from wtspy.m.')
end

% Generates entire x-axis by default, mapping every detail to time. If
% changepoints (cps) are supplied, will only return bracketed time
% interval of the specific changepoint detail each every scale.
num_scales = length(dbe);
do_once = false;

if exist('cps','var')

    % Error catching.
    if ~isnumeric(cps)
        error('''cps'' must be supplied as a numeric array, not cell array.')

    end

    % Make sure there is a changepoint detail for every scale.
    if length(cps)~=num_scales
        error('Supply one detail changepoint index per scale.')

    end

    % This means just return the time domain sample index for the
    % changepoints; don't map an entire x-axis at every scale.
    do_once = true;

end

% Generate time axis to which dbe intervals will be mapped.
xax = xaxis(lx, DELTA, pt0);

% Map every dbe interval from samples to seconds.
for i = 1:num_scales

    % More error catching.
    if ~isnumeric(dbe{i})
        error('dbe{%i} must be numeric. Is of class ''%s''.',i, ...
              class(dbe{i}))

    end


    %% MAIN
    %__________________________%
    if do_once 

        if isnan(cps(i))
            wttime{i} = NaN;
            continue
            
        end

        % Only return time interval of one detail, the changepoint,
        % at every i.
        wttime{i} = xax(dbe{i}(cps(i), :));

    else
        % Project every detail at every i to the time axes to
        % fill an x-axis, e.g. for plotwtspy.m
        for detail = 1:length(dbe{i})
            wttime{i}(detail, :) = xax(dbe{i}(detail, :));

        end

    end

    %__________________________%
    %% END MAIN
end
