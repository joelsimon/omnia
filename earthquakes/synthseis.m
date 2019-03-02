function [synthetic, params] = synthseis(x, cp, dists, abso, ...
                                         dtrnd, bias, stdnorm)
% [synthetic, params] = SYNTHSEIS(x, cp, dists, abso, dtrnd,
%                                  bias, stdnorm)
% 
% SYNTHSEIS generates a synthetic seismogram given an input seismogram
% and a changepoint which separates the noise and signal segments.
%
% Inputs: 
% x                 A seismogram, or its wavelet details (accepts cells)
% cp                Changepoint(s) (1 for 1D; length of cell for wavelets)
% dists             Cell of distribution string names for cpgen.m
%                       (def: {'norm' 'norm'})
% abso              Logical true to work on abs(x) (def: false)
%                      (computes using abs(x);
%                      does not return abs(synthetic))*
% dtrnd             Logical true to linearly detrend noise and signal 
%                       segments before computing parameters (def: false)
% bias              Logical true for biased estimate of variance (def: true)
%                   Logical false for unbiased estimate 
% stdnorm**         Logical true: "Noise" drawn from N(0,1),
%                       and "signal" from N(0, sqrt(SNR)) (def: false)
%                   Logical false: "Noise" drawn from
%                       N(mean(x(1:cp), std(x(1:cp)), and "signal" from
%                       N(mean(x(cp+1:end), std(x(cp+1:end))
% Outputs:
% synthetic         Synthetic seismogram/wavelet details
% params            Parameters calculated from x, applied to dist1,2
%
% * I.e., all(synthetic == abs(synthetic)) is not necessarily true.
%
% ** stdnorm overwrites the following options with these values:
%    dists = {'norm' 'norm'}
%    abso = false
%    dtrnd = false
%
% See also: cpgen.m
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 04-Feb-2019, Version 2017b

%% Recursive.

% Defaults
defval('dists', {'norm' 'norm'})
defval('abso', false)
defval('dtrnd', false)
defval('bias', true)
defval('stdnorm', false)

% Break up cell (if supplied) and run on individual vectors.
if iscell(x)
    cell_len = length(x);
    synthetic = cell(1, cell_len);
    params = cell(1, cell_len);

    for i = 1:cell_len
        [synthetic{i}, params{i}] = synthseis(x{i}, cp(i), dists, ...
                                              abso, dtrnd, bias, stdnorm);
    
    end
else
    % Sanity.
    if ~isfinite(cp) || ~isreal(cp) || ~isint(cp) || cp < 0
        error(sprintf(['cp = %s, but must be finite, real, integer, ' ...
                       'and positive.'], cp))

    end
    lx = length(x);

    % The default is to assume standard normal for noise.  The 'else'
    % statement below allows for more advanced treatment.
    if stdnorm
        dists = {'norm' 'norm'};        
        if bias
            SNR = nanvar(x(cp+1:end), 1) / nanvar(x(1:cp), 1);

        else
            SNR = nanvar(x(cp+1:end), 0) / nanvar(x(1:cp), 0);

        end
        params{1} = {0 1};
        params{2} = {0 sqrt(SNR)};

    else
        % N.B.: Do not use unzip and zipnan here.  In the loop below I simply
        % compute distribution parameter values based on the
        % segmentation; once I've split the input above ("indices") I
        % no longer have to worry about indexing.  I take care of
        % overall indexing at the very end, sliding NaNs into their
        % appropriate place as a final step.

        % Indices of noise and signal segments.
        indices = {1:cp; cp+1:lx};

        % Repeat the parameter estimation twice for noise and signal segments.
        for i = 1:2
            % Parse x vector into it's noise/signal segment.
            segment = x(indices{i});

            % Remove non-finite values from segment to simplify calculations
            % (don't need to use nanmean.m every time...).
            segment = segment(isfinite(segment));

            if abso
                segment = abs(segment);

            end
            if dtrnd
                segment = detrend(segment, 'linear');

            end
            
            % Generating distribution switch.
            switch lower(dists{i})
              case {'norm','normal'}
                if bias
                    vs = var(segment, 1);
                else
                    vs = var(segment, 0);
                end
                params{i} = {mean(segment) sqrt(vs)};

              case {'logn','lognormal'}
                if any(segment < 0)
                    error(['''X'' includes negative values. logn will ' ...
                           'return complex parameters.'])

                end
                params{i} = {mean(log(segment)) std(log(segment))};
                
              otherwise
                error(sprintf(['Distribution type %s not programmed.\nAdd ' ...
                               'parameter estimation to %s.'], dists{i}, mfilename))
                
            end
        end
    end
    % Generate synthetic using parameters estimated from the x per scale.
    synthetic = cpgen(lx, cp, dists{1}, params{1}, dists{2}, params{2});

    % Maybe overwrite some indices with NaNs to match non-finite indices
    % in original x. We need those for possible future cpest.m
    % application. We may introduce bias or error by including more
    % real values in the synthetic than are in original details.
    idx = find(~isfinite(x));
    if ~isempty(idx)
        synthetic(idx) = NaN;

    end
end
