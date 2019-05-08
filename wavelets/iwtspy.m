function [iabe, idbe] = iwtspy(lx, tipe, nvm, n, pph, intel)
% [iabe, idbe] = IWTSPY(lx, tipe, nvm, n, pph, intel)
%
% IWTSPY returns the length of the filters used in inverse wavelet
% transformation.
%
% IWTSPY returns the time-domain sample span smear associated with
% each time-scale domain coefficient index after inverse wavelet
% transformation.  It maps from the time-scale to the time domain,
% while wtspy.m maps from the time to the time-scale.
%
% The forward in and inverse wavelet transform filters are the same
% for tipe = 'Daubechies,' therefore iwtspy.m simply calls wtspy.m in
% that case.
%
% Input:
% lx,...,intel   Inputs to wtpsy.m, see there
%
% Output:
% iabe          Time domain sample span associated with each time-scale 
%                   approximation coefficient index 
% idbe          Time domain sample span associated with each time-scale 
%                   detail coefficient index 
%
% This function is slower than wtspy.m, but for a good reason, which
% is explained at the end of the file.
%
% See also: wtspy.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Jan-2019, Version 2017b

% Defaults and sanity.
defval('tipe', 'CDF')
defval('nvm', [2 4])
defval('n', 5)
defval('pph', 4)
defval('intel', 0)

validateattributes(lx, {'numeric'}, {'even', 'integer'}, 1);

if intel ~= 0;
    error(['iwt.m only works if intel = 0 (cannot reconstruct with ' ...
           'integer rounding)'])

end

% The forward and inverse wavelets are the same for Daubechies.
if strcmp(tipe, 'Daubechies')
    [iabe, idbe] = wtspy(lx, tipe, nvm, n, pph);
    return

end

% Save output in same directory as this calling function.
mfile = which(mfilename);
spyfile = strrep(mfile, [mfilename '.m'], [mfilename '.mat']);

% Set up string to locate experimental info, or save output if
% experiment not yet run.
[pstr, lstr] = wtstr(lx, tipe, nvm, n, pph, intel);
expstr = [pstr '_' lstr];

% Check if precomputed result already exists.
if exist(spyfile, 'file')
    data = load(spyfile);
    IWTSPY = data.IWTSPY;
    clear('data')

    if isfield(IWTSPY, expstr)
        iabe = IWTSPY.(expstr).iabe;
        idbe = IWTSPY.(expstr).idbe;
        return

    end
end

disp('Generating new iwtspy experiment...')

% Transform a time series of zeros to get the output cell sizes.
[a, d, an, dn] = wt(zeros(1,lx), tipe, nvm, n, pph, intel);

% Do once for the approximations.
iabe = NaN(length(a), 2);
for i = 1:length(a)
    a(i) = 1;
    [~, x] = iwt(a, d, an, dn, tipe, nvm, pph); % *See note at bottom.
    iabe(i, :) =  minmax(find(x)');
    a(i) = 0;

end
% minmax(NaN) returns [-Inf +Inf].  Set those indices back to NaN.
% What is physically means: energy at that scale at that coefficient
% is not seen in the original time series.
iabe(~isfinite(iabe)) = NaN;

% Do n times for details.
idbe = celldeal(d, NaN);
for j = 1:length(d)
    idbe{j} = NaN(length(d{j}), 2);

    for i = 1:length(d{j})
        d{j}(i) = 1;
        [~, x] = iwt(a, d, an, dn, tipe, nvm, pph);
        idbe{j}(i, :) =  minmax(find(x)');
        d{j}(i) = 0;

    end
    idbe{j}(~isfinite(idbe{j})) = NaN;

end

% Save the new experiment.
IWTSPY.(expstr).iabe = iabe;
IWTSPY.(expstr).idbe = idbe;
IWTSPY = orderfields(IWTSPY);
save(spyfile, 'IWTSPY', '-mat')
fprintf('\nSaved new iwtspy experiment to %s.\n', spyfile)

% *I use the summed inverse transform, [~,x] = iwt(...), and not the
% partial reconstructions, x = iwt(...), because the partial
% reconstructions are all empty except for the relevant scale I'm
% testing; i.e. the partial reconstruction and the summed inverse are
% the same.


%_________________________________________________________________%

% A note about the speed of this function -- 

% This function is slower than wtspy.m because it is more general than
% wtspy.m (and also requires 'n' times more computations; one for each
% wavelet scale -- we have to run iwt.m 'n' times here; wtspy.m only
% has to run a single forward wavelet transform).  There, all
% experiments are saved in a matrix proportional to [lx * lx].  This
% makes computation fast, but requires a lot of overhead to initiate
% the matrix and thus will fail for long time series. iwtspy.m is more
% general in that it performs each experiment individually, requiring
% much less disk-space to initiate the output (thus allowing for very
% long time series) but much more computation time.
%
% Being that the initial use of iwtspy.m and wtspy.m were to
% characterize the time smear of wavelet coefficients for short
% seismograms upon which AIC picks were made, and that AIC methods
% like short seismograms with single-phase arrivals anyway, perhaps
% the more restrictive but faster method of wtspy.m is preferable to
% the slower but more general method here. Perhaps both functions
% would benefit from a switch statement that used procedures based on
% length of the input.
