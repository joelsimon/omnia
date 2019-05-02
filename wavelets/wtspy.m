function varargout = wtspy(lx, tipe, nvm, n, pph, intel)
% [abe, dbe, sp, cdn] = WTSPY(lx, tipe, nvm, n, pph, intel)
%
% WTSPY returns the length of the filters used in forward wavelet
% transformation.
%
% WTSPY returns the samples seen by each approximation and/or detail
% coefficient at every scale.  It defines a time-scale to time domain
% mapping.  It is essentially the opposite of wtcoi.m.  
%
% 'abe' and 'dbe' are bracketed sample intervals [start end]. They are
% the projection of the sample span of every approximation or detail
% from the time-scale domain to the time domain. E.g., detail{1}(1) is
% only one detail, though it may project onto 40 samples in the
% original time series if the wavelet has a large cone of influence
% (is a wide basis).
%
% 'sp' is the "influence matrix" of a particular wavelet transform
% implementation.  It compiles all abe (approximation coefficients)
% and dbe (detail coefficients) intervals into a single large, sparse,
% matrix.  Every dbe{j}, where j is a scale, is simply 'sp' parsed at
% that specific j.
%
% Read vertically: 'sp' defines the time-to-detail (& approx.) mapping
% Read horizontally: 'sp' defines the detail-to-time (& approx.) mapping
%
% This algorithm was designed specifically for MERMAID data, which are
% time series generally less than 6000 samples in length.  This
% algorithm preallocates a large matrix based on the size of the input
% time series and thus breaks if lx is too large.  An updated version
% would need to iterate every scale individually and use minmax to set
% up an [2 x lx] array which could then be read horizontally to find
% abe, dbe.  This would be slower but more robust.  Alternatively, it
% could be refactoring to run in parallel.
%
% Input:  
% lx          The length of the time series to be analyzed
% tipe        'Daubechies', 'CDF', or 'CDFI' (def: 'CDF')
% nvm         Number of vanishing (primal & dual) moments
%                 (def: [2 4])
% n           Number of filter bank iterations (levels)
% pph         Method of calculation (def: 4)
%             1 Time-domain full bitrate (inefficient)
%             2 Time-domain polyphase (inefficient)
%             3 Z-domain polyphase (fast)
%             4 Lifting (only for biorthogonal ones)
% intel       [For lifting only] (def: 0)
%             1  With integer rounding 
%             0 Without integer rounding 
%
% Output: 
% abe         First and last sample each scaling coefficient sees 
%                 at each scale
% dbe         First and last sample each detail coefficient sees 
%                 at each scale (in a cell for each scale)
% sp          Wavelet transform "influence" matrix. The rows are the positions
%                 of wavelet/scaling coefficients under the particular
%                 transform, ordered from fine to coarse details
%                 (wavelets) and ending with the coarsest approximation
%                 (scaling functions). The columns are the positions of
%                 a spike in a time series of length lx that serves as an
%                 input. The values indicate the extent to which a
%                 particular input position "hits" a particular wavelet
%                 or scaling coefficient.
% cdn         Row index where the scale levels or coefficient
%                 types switch in sp** 
%
%
% ** e.g.: if dn=[13,9,7,6,6], cdn=[1,14,23,30,36,42], and therefore
% d{1}=sp(1:13,:), d{2}=sp(14:22,:), ... , a=sp(42:end,:)
%
% Ex: Find samples seen by detail index 231 at scale 2.
%    x = cpgen(1000, 500);
%    [abe, dbe] = WTSPY(length(x), 'CDF', [2 4], 5, 4, 0);
%    fprintf('Detail index 231 sees samples [%i:%i] in x at scale 2.\n',  ...
%           dbe{2}(231,1), dbe{2}(231,2))
%
% See also: wtxaxis.m, plotwtspy.m, smoothscale.m, wtcoi.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 28-Dec-2018, Version 2017b

% Defaults.
defval('tipe', 'CDF')
defval('nvm', [2 4])
defval('pph', 4)
defval('intel', 0)

% Sanity. Pass the length of x, not x itself.
validateattributes(lx, {'numeric'}, {'real' 'integer' 'positive' ...
                    'numel' 1}, mfilename, 'lx')

% Save output in same directory as this calling function.
mfile = which(mfilename);
spyfile = strrep(mfile, [mfilename '.m'], [mfilename '.mat']);

% Set up string to locate experimental info, or save output if
% experiment not yet run.
[pstr, lstr] = wtstr(lx, tipe, nvm, n, pph, intel);
expstr = [pstr '_' lstr];

% Sentinel value: precomputed results file exists.
if exist(spyfile, 'file')
    spyexists = true;

else
    spyexists = false;

end

% Sentinel value: this specific experiment exists in the precomputed results.
if spyexists
    % Must load data in this way and reassign WTSPY to data.WTSPY so this
    % function may be used in a parfor loop.
    data = load(spyfile);
    WTSPY = data.WTSPY;
    clear('data')

    if isfield(WTSPY, expstr)
        expexists = true;

    else
        expexists = false;

    end

end

% Sentinel value: sparsity matrix output ('sp') is requested.
if nargout > 2
    sprequested = true;

else
    sprequested = false;

end

if expexists && ~sprequested
    % Requested experiment exists in precomputed results and full sparsity
    % matrix ('sp') is not requested as output.  Load output and exit.
    abe = WTSPY.(expstr).abe;
    dbe = WTSPY.(expstr).dbe;
    outargs = {abe, dbe};

else
    % Either the full sparsity matrix ('sp') was requested as output
    % (which isn't saved in the 'spyfile'), and/or the experiment
    % requested doesn't exist in the precomputed results 'spyfile'.
    disp('Generating new wtspy experiment...')

    % Calculate WT once outside loop to initialize final matrix
    % dimensions.
    [a, d, an, dn] = wt(zeros(1,lx), tipe, nvm, n, pph, intel);
    sp = zeros(an(end) + sum(dn), lx);
    
    % This is the main routine.
    for i = 1:lx
        % See note *(1) at bottom.
        [a, d] = wt(full(sparse(1,i,1,1,lx)), tipe, nvm, n, pph, intel); 
        sp(:,i) = [cat(1,d{:}) ; a];

    end

    % Find first and last instance of nonzero coeff. per row;
    % cbce='coeff. beginning, coeff. ending'
    [r, c] = find(sp);
    cb = accumarray(r, c, [], @min); 
    ce = accumarray(r, c, [], @max);
    cbce = [cb ce];

    % Set up index vector for plotting purposes, where coeff. type
    % switches in sp.
    cdn = [1 cumsum(dn)+1];

    % For every row, assemble the beginning and end back into an 'abe'
    % vector and a 'dbe' cell which are of the identical dimensions as
    % what WT returns.
    for i = 1:length(cdn)-1
        dbe{i} = cbce(cdn(i):cdn(i+1)-1,:);

    end

    % Put scaling coeffs ('a') at end.
    abe = cbce(cdn(end):length(cbce), :);
    
    % If the savefile doesn't exist, there is nothing to append, so
    % you're done. Exit if statement and collect vars.
    % Else, if this field doesn't exist in master structure, add it.
    if ~expexists
        % Need to save this specific experiment.
        WTSPY.(expstr).abe = abe;
        WTSPY.(expstr).dbe = dbe;
        WTSPY = orderfields(WTSPY);
        save(spyfile, 'WTSPY', '-mat')
        fprintf('\nSaved new wtspy experiment to %s.\n', spyfile)

    end

    % Collect output arguments.
    outargs = {abe, dbe, sp, cdn};
end

% Collect outputs.
varargout = outargs(1:nargout);


% *(1) 10-Aug-2018: Verified that the nonzero value of the spike doesn't
% affect output 'dbe', or the nonzero components of 'sp'.  E.g.,
% full(sparse(1,index,1e9,1,lx)) gives the same outputs as
% full(sparse(1,index,1.0,1,lx)) (though the actual values of 'sp' are
% different).

% *(2) 14-Aug-2018: There is some weirdness sometimes with lifting
% where the second to last index will see the edge but not the last
% index.  Therefore, in wtedge.m set all indices before the LAST
% detail you see the start of time series (e1), and after the FIRST
% detail at which you see the end of the time series, to nan.  Also,
% I'm checking both columns just to be sure safe; I don't know if
% maybe the wavelet flips in some algorithms so it would see the end
% of the signal in the first column but not the last (e.g.,
% dbe{1}(end,:) = [1000 999]).
