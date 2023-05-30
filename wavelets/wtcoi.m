function [coi, coibe, precede] = wtcoi(dabe, samp, lx)
% [coi, coibe, precede] = WTCOI(dabe, samp)
%
% WTCOI returns the cone of influence of a single sample in the time
% domain, i.e. the time-scale indices that contain ('see'; are
% sensitive to; influenced by) said sample.
%
% WTCOI is useful in projecting a "noise" and "signal" segmentation
% from the time domain into the time-scale (wavelet) domain.  For
% example, assume the arrival (first sample of "signal") is sample
% 500, then 'coi' tells you all time-scale indices that are sensitive
% to sample 500, 'coibe' summarizes the cone of influence and tells
% you only the first and last time-scale indices that are sensitive to
% sample 500, and 'precede' tells you the last time-scale index of the
% noise section (the last time-scale index whose time smear is
% completely contained in the sample span before sample index 500).
%
% Note the author defines the end of the "noise" segment as the last
% time-scale index which ONLY sees "noise."  Due to time smear of
% time-scale indices one must decide whether the "noise" or the
% "signal" segmentation includes a mixture of the other.  The author
% has deliberate the choice that it is better to have a little "noise" mixed
% into the "signal" segmentation than the reverse.  I.e., the "noise"
% is purely "noise."  The "signal" may have a little "noise" mixed in
% at the start of the segmentation.  See example 2 below.
%
% Input:
% dabe         abe (input as cell, {abe}) or dbe from wtspy.m
% samp         Time-domain sample index of interest
% lx           Length of original time series (def: max(dabe))
%
% Output:
% coi          Cell of ALL time-scale indices that see the input sample,
%                  at each scale (returns [] if samp out of range)
% coibe        Cell of first and last time-scale indices that see the input
%                  sample, at each scale (returns [] if samp out of range)
% precede      Array of the last time-scale index that does NOT see the sample
%                 of interest, i.e., the last time-scale index which is
%                 completely in the "noise" segment, at each scale
%                 (returns NaN if none exist, i.e., samp = 1)
%
% For examples 1--3 below first run:
%    lx = 1000 ; x = cpgen(lx, 500);
%    [a, d] = wt(x, 'CDF', [2 4], 5, 4, 0);
%    [abe, dbe] = wtspy(length(x), 'CDF', [2 4], 5, 4, 0);
%
% Ex1: Approximation indices that see sample 500 (note the braces {})
%    [acoi, acoibe] = WTCOI({abe}, 500, lx)
%
% Ex2: Detail indices that see sample 500
%    [dcoi, dcoibe] = WTCOI(dbe, 500, lx)
%
% Ex:3 Detail indices that precede sample 4: none found for scales 2:5
% because sample 4 is seen by the first detail index at those scales
%    [~, ~, precede] = WTCOI(dbe, 4, lx)
%
% Ex4: Start of "signal" at sample 736 -- find last detail which is solely
%       in the "noise" segment at each scale.
%    x = normcpgen(1000, 736, 10);
%    [~, d]  = wt(x, 'CDF', [1 1], 2, 4, 0);
%    [~, dbe]  = wtspy(length(x), 'CDF', [1 1], 5, 4, 0);
%    [~, ~, precede] = WTCOI(dbe, 736, lx);
%    % Check the samples precede now record.
%    for i = 1:length(precede)
%         endofnoise{i} = dbe{i}(precede(i),:);
%         startofsignal{i} = dbe{i}(precede(i)+1,:);
%    end
%    % Note the last detail of the "noise" segment includes no
%    % signal -- it never 'sees' sample 736.
%    celldisp(endofnoise)
%    % Though the first detail of the "signal" segment includes
%    % some "noise" (samples which precede 736).
%    celldisp(startofsignal)
%
% See also: wtxaxis.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 30-May-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Changelog - this is way out of date; left for reference but use .git log instead
%
% UPDATE to 26-Nov-2018: Found a case where dabe doesn't reach lx:
% [abe, dbe] = wtspy(length(x), 'CDF', [1 1], 5, 4, 0)
% See dbe{4}.
%
% 26-Nov-2018: Added lx input to ensure 'out of range' outputs handled
% correctly (I can't think of a case when the max of dabe wouldn't be
% lx, but I added it here just in case).  Left option to default to
% use max.
%
% 27-Jul-2018: Removed sanity check that threw error if sample out of
% dabe range and instead return [].  Added second output of first and
% last details which see the input sample.

% Sanity.
validateattributes(dabe, {'cell'}, {}, 1)
validateattributes(samp, {'numeric'}, {'integer'}, 2)
validateattributes(lx, {'numeric'}, {'integer'}, 3)

% Default length: presumes maximum of dabe represents the total length of the original signal.
defval('lx', max(cellfun(@(xx) max(xx(:)), dabe)))

% Return empties and exit is sample out of range.
if samp < 1 || samp > lx
    coi = {};
    coibe = {};
    precede = [];
    warning('Requested sample out of dabe range')
    return

end

for i = 1:length(dabe)
    % Find all time-scale coefficients that contain the sample of
    % interest.
    coi{i} = find(dabe{i}(:,1) <= samp & dabe{i}(:,2) >= samp);
    if isempty(coi{i})
        coibe{i} = {};
        coibe2{i} = {}; % `minmax` fix test var to check edit; see below
        precede(i) = NaN;
        continue

    end

    % Nab the first and last time-scale indices found above.
    coibe{i} = minmax(coi{i}');

    % 18-May-2023: `minmax` errored for Dalija because she did not have the required
    % toolbox; Joel made the below edit and is now tracking it to ensure it
    % performs equally.
    mn = min(coi{i});
    mx = max(coi{i});
    coibe2{i} = [mn mx];

    if ~isequal(coibe, coibe2)
        error('`minmax` fix not working as expected')

    end

    % Return the last time-scale index that precedes the those found
    % above; i.e., the last time-scale index which is completely
    % contained in the "noise" segmentation if 'samp' is the arrival,
    % or start of the "signal" section).
    precede(i) = coi{i}(1) - 1;

    % If coi(1) is 1 (sample 1 is the start of the "signal") then that
    % would mean 'precede '(last sample of the "noise") is 0.
    % That's nonphysical, there's no 0 index. Don't set to [];
    % this isn't a cell so array indexing will get screwed up.
    if precede(i) < 1
        precede(i) = NaN;

    end
end
