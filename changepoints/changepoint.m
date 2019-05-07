function  CP = changepoint(domain, x, n, delta, pt0, snrcut, inputs, conf, fml)
% CP = CHANGEPOINT(domain, x, n, delta, pt0, snrcut, inputs, conf, fml)
%
% Multiscale time series changepoint and arrival time detector with
% error estimations.  See xaxis.m / wtxaxis.m to understand how
% CHANGEPOINT handles time.
%
% Input:
% domain     'time' or 'time-scale' (def: 'time')
% x          The time series to be analyzed
% n          Number of scales of wavelet decomposition
% delta      Sampling interval in seconds (delta in SAC header)
% pt0        Time (s) to set fist sample (def: 0 seconds)
% snrcut     Cutoff above which the SNR must be to to be considered
%                an "arrival" (def: 1)
%                (use NaN or -inf, NOT [], to ignore this input)
% inputs     Structure of other, less commonly adjusted inputs, 
%                e.g., wavelet type (def:  cpinputs, see there)
% conf      -1: skip confidence interval estimation with cpci.m (def)
%            0  compute confidence interval with cpci.m
%            1: compute confidence interval with cpci.m, M1 only
% fml        Smoothing, for 'time-scale' domain only:
%            'first': smooths all times to start of dabe smear
%            'middle: smooths all times to middle of dabe smear
%            'last': smooths all times to end of dabe smear
%            []: return complete time smear (def)
%
% Output:    Changepoint structure, CP, with fields:
% domain: 'time' or 'time-scale'
%      x: the input time series, detrended and possibly with 1 sample removed
% inputs: structure of inputs to changepoint 
%outputs: structure of outputs not deemed worthy of the top level
%     ci: confidence interval, if computed
% cpsamp: changepoint index (time domain samples)**
% cpsecs: changepoint time (s)**
% arsamp: arrival index (time domain samples)**
% arsecs: arrival time (s)**
%   SNRj: SNR at every scale
%
% **if domain == 'time-scale' and 'fml' == [], these are returned as
% 2x1 cells which bracket the time smear.
%
% The values in the top level of the CP structure are all in
% the time domain, e.g., the arrival time is in seconds, even if it
% was found in the 'time-scale' domain and mapped back.  All
% domain-specific outputs are stored in the .outputs structure for
% reference.
%
% For example, the time-scale domain changepoint coefficient index at
% the first scale in example 1, below, is,
%                   
%                   CP.outputs.cp(1) = 208.
%
% The time domain changepoint sample indices are
%
%                   CP.cpsamp{1} = [415 417].
%
% I.e., time-scale coefficient index 208 at scale 1 maps to time
% domain sample indices [415:417].  This can be verified with
%
%    CP.outputs.dabe{1}(CP.outputs.cp(1), :) = [415 417]
%
% Ex1: Detail changepoint sample at scale 1 after 5 scales of decomposition.
%    sacf = 'm12.20130416T105310.sac';
%    [x, h] = readsac(sacf);
%    CP = CHANGEPOINT('time', x, 3, h.DELTA, h.B)
%    figure; plot(x); vertline(CP.cpsamp{1});
%    xlabel('sample'); ylabel('amplitude')
%
% Ex2: Detail changepoint time (s) at scale 1 after 5 scales of decomposition.
%    sacf = 'm12.20130416T105310.sac';
%    [x, h] = readsac(sacf);
%    CP = CHANGEPOINT('time', x, 3, h.DELTA, h.B)
%    figure; plot(CP.outputs.xax, CP.x); vertline(CP.cpsecs{1});
%    xlabel('time (s)'); ylabel('amplitude')
%
% Ex3: Changepoint estimation made in time-scale domain and plotted at scale 3, 
%      note time domain smear of changepoint detail at scale 3 (see CP.dbe{3}).
%    sacf = 'm12.20130416T105310.sac';
%    [x, h] = readsac(sacf);
%    CP = CHANGEPOINT('time-scale', x, 3, h.DELTA, h.B)
%    figure; plot(CP.x); vertline(CP.cpsamp{3});
%    xlabel('sample'); ylabel('amplitude')
%
% See also: cpest.m, cpci.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 14-Feb-2019, Version 2017b

% Default I/O.
defval('domain', 'time')
defval('pt0', 0);
defval('snrcut', 1);
defval('inputs', cpinputs)
defval('conf', -1)
defval('fml', [])
ci = [];
rawci = [];

% Sanity.
if conf ~= -1 && ~isempty(fml)
    error(['Cannot compute confidence interval if scales smoothed ' ...
           'with ''fml'''])

end
if islogical(conf)
    error(sprintf(['Type: logical is not allowed for input: conf.\' ...
                   'nSpecify one of -1, 0, or 1.']))

end

% It is true some methods of iwt.m calculation (e.g., Z-domain
% polyphase; pph = 3) do work if x is an odd-length array, but to
% always compare apples-to-apples (e.g., differences due to the method
% of calculation itself) make x an even length array by removing the
% last sample.
x = x(:);
if mod(length(x), 2) 
    x = x(1:end-1);

end
x = detrend(x, 'linear');

% Wavelet transform with edges removed (most likely, adjust with inputs.rmedge).
[a, abe, iabe, d, dbe, idbe, ae1, ae2, de1, de2, an, dn] = ...
    wtrmedge(domain, x, inputs.tipe, inputs.nvm, n, inputs.pph, ...
             inputs.intel, inputs.rmedge);

% Concatenate wt.m outputs, ordered high to low resolution details,
% then approximation.
dabe = [dbe abe];
idabe = [idbe iabe];
da = [d a];
dnan = [dn an]; %*
e1 = [de1 ae1];
e2 = [de2 ae2];
%* These are number of detail/approx. at each scale; NOT the edge
%coefficients set to NaN

% If requested, smooth time-scale domain coefficient time smears.
if strcmp(domain, 'time-scale') && ~isempty(fml) 
    dabe = smoothscale(dabe, fml);

end

% Main changepoint detecting routine.
switch inputs.cptype
  case 'kw'
    [cp, ~, aicj, weights] = cpest(da, inputs.algo, inputs.dtrnd, inputs.bias);
    
  case 'km'
    [~, cp, aicj, weights] = cpest(da, inputs.algo, inputs.dtrnd, inputs.bias);

end

% Compute SNR and power distribution across the scales.
SNRj = wtsnr(da, cp, inputs.meth);

% Generate time axis.
lx = length(x);
xax = xaxis(lx, delta, pt0);

% Generate wavelet transform time axis (in seconds, not samples).
wtxax = wtxaxis(dabe, lx, delta, pt0);

% The two methods differ in how the changepoint and arrival SAMPLES
% are found....
for i = 1:length(cp)    
    if ~isnan(cp(i))
        if strcmp(domain, 'time-scale')
            cpsamp{i} = dabe{i}(cp(i), :);
            arsamp{i} = dabe{i}(cp(i) + 1, :); % *See note below.
            
        else
            cpsamp{i} = cp(i);
            arsamp{i} = cpsamp{i} + 1;

        end
    else
        cpsamp{i} = NaN;
        arsamp{i} = NaN;

    end
end
% *Note: arsamp{i} = dabe{i}(cp(i) + 1, :), NOT
%        arsamp{i} = cpsamp{i} + 1
% These are not the same.

% ...though once the samples are identified the mapping from samples
% to seconds is straightforward and the same for both.
for i = 1:length(cp)
    if ~isnan(cp(i))
        cpsecs{i} = xax(cpsamp{i})';
        arsecs{i} = xax(arsamp{i})';
        
    else
        cpsecs{i} = NaN;
        arsecs{i} = NaN;

    end
end

% Set the "arrivals" to NaN if SNR <= snrcut, but leave the
% changepoints as is, because they don't presume energy increases from
% left to right, necessarily.
if isempty(snrcut)
    snrcut = -inf;

end
for i = 1:length(cp)
    if SNRj(i) <= snrcut
        arsamp{i} = NaN;
        arsecs{i} = NaN;
            
    end
end

% Estimate the changepoint confidence interval, if requested, and
% convert to time (s) from time domain sample indices or time-scale
% domain coefficient indices.
if conf ~= -1
    if conf == 1
        [ci.M1] = cpci(da, inputs.cptype, inputs.iters, inputs.alphas, ...
                       inputs.algo, inputs.dtrnd, inputs.bias, ...
                       inputs.dists, inputs.stdnorm);
        ci.M2 = [];
        
    elseif conf == 0
        [ci.M1, ci.M2] = cpci(da, inputs.cptype, inputs.iters, ...
                              inputs.alphas, inputs.algo, inputs.dtrnd, ...
                              inputs.bias, inputs.dists, inputs.stdnorm);
        
    else
        error('Specify one of -1, 0, or 1 for input: conf')

    end

    % Save domain-specific ci in 'rawci' output.
    rawci = ci;
    
    % Output of cpci.m is domain specific, and not in seconds.
    % If domain = 'time', cpci.m is in time domain samples (k)
    % If domain = 'time-scale', cpci.m is in time scale-domain
    %             coefficient indices (l)
    for i = 1:length(cp)
        if ~isnan(cp(i))
            if strcmp(domain, 'time-scale') 
                % Time domain sample span of time-scale changepoint estimate
                % coefficient index.  Multiplying the confidence
                % interval by this smear converts from time-scale
                % domain to time domain sample indices, below.
                %
                % Add one sample because diff is not a length.
                smear = diff(dabe{i}(cp(i), :)) + 1;

            else
                % There is no time smear associated with the
                % changepoint estimate made in the time-domain --
                % it's a single time domain sample index.
                smear = 1;

            end
            % Multiply every field of ci.M1 by the time smear and sampling
            % interval to convert to seconds.  Do not need to remove 1
            % sample from these errors (as done below with M2) because
            % the error of 1 sample equals the sampling interval
            % (not 0 seconds, as is the case for a length 1 interval).
            ci.M1(i) = structfun(@(xx) xx * smear * delta, ci.M1(i), ...
                                 'UniformOutput', false);

            if conf == 0
                % Multiply every field of ci.M2 by the time smear and sampling
                % interval to convert to seconds (except for 'h1' the null
                % hypothesis rejection percentage...hence we can't use
                % structfun here).  Remove 1 sample from the scaled sample
                % spans before multiplying by the sampling interval to
                % convert to seconds because these are durations (the
                % duration of 1 sample is 0 seconds).
                %
                % No need to worry about negative or < 1 length spans due
                % to definition of M2 span (see cpci.m).
                for j = {'restricted' 'unrestricted'}
                    ci.M2(i).(j{:}).six8 = ...
                        ([ci.M2(i).(j{:}).six8 * smear] - 1) * delta;
                    ci.M2(i).(j{:}).nine5 = ...
                        ([ci.M2(i).(j{:}).nine5 * smear] - 1) * delta;
                    ci.M2(i).(j{:}).span = ...
                        ([ci.M2(i).(j{:}).span * smear] - 1) * delta;

                end
            end 
        end
    end
end

% Organize output structure.
inputs.n = n;
inputs.delta = delta;
inputs.pt0 = pt0;
inputs.snrcut = snrcut;
inputs.conf = conf;
inputs.fml = fml;

outputs.xax = xax;
outputs.wtxax = wtxax;
outputs.cp = cp;
outputs.rawci = rawci;
outputs.da = da;
outputs.dnan = dnan;
outputs.dabe = dabe;
outputs.idabe = idabe;
outputs.e1 = e1;
outputs.e2 = e2;
outputs.aicj = aicj;
outputs.weights = weights;

% Final.
CP.domain = domain;
CP.x = x;
CP.inputs = inputs;
CP.outputs = outputs;
CP.ci = ci;
CP.cpsamp = cpsamp;
CP.cpsecs = cpsecs;
CP.arsamp = arsamp;
CP.arsecs = arsecs;
CP.SNRj = SNRj(:)';
