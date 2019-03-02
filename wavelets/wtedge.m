function [a, d, ae1, ae2, de1, de2] = wtedge(domain, lx, a, abe, ...
                                             iabe, d, dbe, idbe, rmedge)
% [a, d, ae1, ae2, de1, de2] = WTEDGE(domain, lx, a, abe, ...
%                                     iabe, d, dbe, idbe, rmedge)
%
% WTEDGE returns (and possibly sets to NaN) the edges of a
% wavelet-transformed time series.
%
% There is a larger span of samples sensitive to the edge in the
% 'time' domain than 'time-scale' domain because the former requires a
% second inverse wavelet transform to occur before the edges are
% removed, effectively overlapping detail or approximation time smears
% which don't see the edge with ones that do.  Ergo, even if a detail
% doesn't see the edge, if it has some overlap with a detail that does
% see the edge, it will be considered to be influenced by the edge and
% thus handled appropriately by setting to NaN.  In the case of
% 'time-scale' domain there is only a single, forward wavelet
% transformation, meaning that every detail or approximation is
% considered independent, and thus only those dabe time smears which
% touch the edge must be removed.  See Ex3 below for more.
%
% Input:
% domain   'time-scale' (wt.m) -OR- 'time' (iwt.m)
% lx        Length of input time series
% a         Approximation (scaling) coefficients from wt.m 
%                -OR- their partially reconstructed 
%                time domain samples from iwt.m (def: [])
% abe       Approximation coefficient time smear from wtspy.m (always required)
% iabe      Inverse approximation coefficient time smear from iwtspy.m
%               (def: {})
% d         Detail (wavelet) coefficients from wt.m -OR-
%               their partially reconstructed time domain 
%               samples from iwt.m (def: [])
% dbe       Detail coefficient time smear from wtspy.m (always required)
% idbe      Inverse detail coefficient time smear from iwtspy.m
%               (def: {})
% rmedge    logical true to set edges to NaN (def: true)
%
% Output:
% a, d      Input, possibly with edges set to NaN
% ae1/2     Approximation indices or partial reconstruction samples
%               that see sample 1, lx (the 'edges')
% de1/2     Detail indices or partial reconstruction samples
%               that see sample 1, lx (the 'edges')
%
% For both examples below first run:
%    x = randn(1,32);
%    [a, d, an, dn]  = wt(x, 'CDF', [1 1], 2, 4, 0);
%    xj  = iwt(a, d, an, dn, 'CDF', [1 1], 4);
%    [xja, xjd] = iwtj2wtj(xj);
%    [abe, dbe]  = wtspy(length(x), 'CDF', [1 1], 2, 4, 0);
%    [iabe, idbe] = iwtspy(length(x), 'CDF', [1 1], 2, 4, 0);
%
% Ex1: Time-scale domain -- a(1) and a(8) are set to NaN because they
% represent the time-scale indices whose corresponding time smears
% include samples 1 and 32, respectively (see abe, below). The inverse
% filter lengths length (ia/dbe) are not required for the 'time-scale'
% domain,
%
%     [a2, d2] = WTEDGE('time-scale', length(x), a, abe, [], d, dbe, [], true)
%
% Ex2: Time domain -- a(1:4) and a(29:32) are set to NaN because they
% are the time smears associated with time-scale indices 1 and 8,
% respectively, from example 1 above.  All inputs are required for the 'time' domain,
%
%     [ap2, dp2] = WTEDGE('time', length(x), xja, abe, iabe, xjd, dbe, idbe, true)
%
% In the above examples:
%
% abe =
%      1     4   (ae1, time-scale index 1)
%      5     8
%      9    12
%     13    16
%     17    20
%     21    24
%     25    28
%     29    32  (ae2, time-scale index 8)
%
% 
% Ergo, for the approximations, time-scale index 1 corresponds to time
% domain samples [1:4], and time-scale index 8 corresponds to time
% domain samples [29:32].  The 'domain' input here simply alerts the
% algorithm of the requested output domain: 1 or 4 for ae1, and 8 or
% 29 for ae2 (similar story for details).
% 
% Ex3: More realistic example showing difference in 'time' vs 'time-scale', 
%      using changepoint.m, which calls wtedge with edges removed by default
%    x = randn(4000, 1);
%    CPts = changepoint('time-scale', x, 5, 1, 1);
%    CPt = changepoint('time', x, 5, 1, 1);
%    % Look at the right edge in both cases.
%    CPts.outputs.e2{end}               
%    CPt.outputs.e2{end}
%    % And look at the dabe time smears (same for both)
%    isequaln(CPt.outputs.dabe{end}, CPts.outputs.dabe{end})
%    CPt.outputs.dabe{end}
% 
% Because the right edge at the last scale (the approximation) is seen
% all the way to sample 3781 in the 'time' domain, we define e2 as
% 3781, and thus all samples from [3781:end] are set to NaN.
% Conversely, in the 'time-scale' domain the right edge is seen all
% the way down to time-scale index 123.  Because there is no second
% inverse transform in this domain, all dabe time smears are
% independent of one another, thus dabe time smear 122 is not aware
% that it is near the edge.  Therefore da{end}(123:125) are set to
% NaN, meaning that after projection back into the time domain, the
% last dabe coefficient that doesn't see the edge is 122, which ends
% at sample 3997.
%
% See also: wtrmedge.m, wt.m, iwt.m, wtspy.m, wtcoi.m, iwtj2wtj.m
%
% Documented pp. 140-143, 2017.1
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Jan-2019, Version 2017b

% Default I/O.
defval('iabe', []);
defval('idbe', {});
defval('rmedge', true)
ae1 = [];
ae2 = [];
de1 = [];
de2 = [];


% Concatenate inputs.
da = [d a];
dabe = [dbe abe];
idabe = [idbe iabe];

%% filters in the case of time domain, ergo we must always compute the
%% forward wavelet transform time smears, even if we don't end up using
%% them.

%% FORWARD WAVELET TRANSFORM TIME SMEARS
% Find the cone of influence of sample 1 and sample lx.
coi_e1 = wtcoi(dabe,  1, lx);
coi_e2 = wtcoi(dabe, lx, lx);

%% INVERSE WAVELET TRANSFORM TIME SMEARS
% coi* found above are smears in the time-scale domain. Alternatively
% we have smears in the time domain due to a single time-scale
% coefficient.  Pull those up in the case of domain='time' because
% they are relevant for the lengths of the inverse reconstruction
% filters.  Use the longer of the two as your cone.
if strcmp(domain, 'time')
    icoi_e1 = wtcoi(idabe,  1, lx);
    icoi_e2 = wtcoi(idabe, lx, lx);

end

e1 = cell(1, length(da));
e2 = cell(1, length(da));
for i = 1:length(dabe)
    switch domain
      case 'time-scale'
        % Last time-scale index that sees first time domain sample.*
        if ~isempty(coi_e1{i})
            e1{i} = max(coi_e1{i});

        else
            e1{i} = [];

        end

        % First time-scale index that sees last time domain sample.*
        if ~isempty(coi_e2{i});
            e2{i} = min(coi_e2{i});

        else
            e2{i} = [];

        end

      case 'time'
        % Last time domain sample corresponding to the last time-scale domain
        % index that sees the first sample.*
        if ~isempty(coi_e1{i}) ||  ~isempty(icoi_e1{i})
            forward_e1 = max(max(dabe{i}(coi_e1{i}, :)));
            inverse_e1 = max(max(idabe{i}(icoi_e1{i}, :)));
            e1{i} = max([forward_e1 inverse_e1]);

        else
            e1{i} = [];

        end

        % First time domain sample corresponding to the first time-scale
        % domain index that sees the first sample.*
        if ~isempty(coi_e2{i}) || ~isempty(icoi_e2{i})
            forward_e2 = min(min(dabe{i}(coi_e2{i}, :)));
            inverse_e2 = min(min(idabe{i}(icoi_e2{i}, :)));
            e2{i} = min([forward_e2 inverse_e2]);

        else
            e2{i} = [];

        end
    end

    if rmedge
        da{i}(1:e1{i}) = NaN;
        da{i}(e2{i}:end) = NaN;
        
    end

end

% Parse approximation and details which were concatenated above.
% Return approximation as an array and details as a cell, as is done
% in wt.m.
if isempty(a)
    d  = da;
    de1 = e1;
    de2 = e2;

elseif isempty(d)
    a  = da{:};
    ae1 = e1{:};
    ae2 = e2{:};

else
    d  = da(1:end-1);
    de1 = e1(1:end-1);
    de2 = e2(1:end-1);

    a = da{end};
    ae1 = e1{end};
    ae2 = e2{end};

end

%____________________________________________________________________%

% *N.B: In all cases it is last to see first sample, and first to see
% last sample.  In some odd cases due to the wt.m algorithm it can
% happen that the second to last detail will see the edge of the time
% series, but the last detail will not.  Ergo, we must search from
% inward from the edge on both sides, finding all a/dbe which include
% edge sensitivity, keeping the detail furthest from the edge as our
% choice.  We cannot simply find those a/dbe indices which include 1
% or lx.  For example:
%
% [~, dbe] = wtspy(1000, 'CDF', [2 4], 5, 4, 0);
%
% See dbe{2} -- dbe{2}(end-1,:) sees edge sample 1000; dbe{2}(end,:)
% does not.  If we only set to NaN the the indices which had edge
% sensitivity (via a find(...)) we would set dbe{2}(end-1) to NaN but
% not dbe{2}(end).  It seems more appropriate to set both to NaN
% considering this is just an algorithmic oddity in wt.m.
