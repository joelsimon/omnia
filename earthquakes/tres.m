function res = tres(sac, diro, inputs)
% res = TRES(sac, diro, inputs)
%
% TRES computes the travel time residuals associated with the input
% SAC file where the user-pick is defined in the 'time' domain using
% changepoint.m and the theoretical travel time in defined in the
% reviewed .evt file.  Only the first event in the reviewed .evt file
% is considered here for computation of time residuals.
%
%          res = min([CP.arsecs - EQ(1).truearsecs]
%
% Inputs:
% sac        Full path SAC filename
% diro       Path to directory containing 'raw/' and 'reviewed' 
%                subdirectories (def: $MERMAID/events/)
% inputs     Structure of optional inputs for changepoint.m
%                (def: cpinputs)
%
% Output:
% res        Travel time residual in sec
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 19-Mar-2019, Version 2017b

% Defaults.
defval('sac', '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
defval('diro', fullfile(getenv('MERMAID'), 'events'))
defval('inputs', cpinputs)

% Load the EQ structure(s) from the reviewed .evt file.
[EQ, ~, ~, ~, rev_evt] = getevt(sac, diro, false);

% Ensure the reviewed .evt file (and thus EQ structure just loaded) exists.
sacname = strippath(sac);
if isempty(rev_evt)
    error('No .evt file associated with %s found (recursively) in\n%s', strippath(sac), diro)

end

% Read the seismic data and metadata.
[x, h] = readsac(sac);

% The number of wavelet scales of the decomposition is determined by
% the sampling frequency.
switch efes(h)
  case 5
    n = 3
    padd = [NaN NaN]
    
  case 20
    padd = [];

  otherwise
    error('Not programmed to NaN-pad for a sampling frequency of %i [Hz]', efes(h))

end

keyboard
% Compute changepoint structure using entire SAC seismogram and inputs requested.
CP = changepoint('time', x, n, h.DELTA, h.B, 1, inputs, 1);


keyboard

