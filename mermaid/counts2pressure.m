function [Pa, m] = counts2pressure(counts)
% [Pa, m] = COUNTS2PRESSURE(counts)
%
% COUNTS2PRESSURE converts raw amplitude counts of the
% third-generation MERMAID (manufactured by Osean.fr) into their
% representative pressure [Pa] and equivalent perturbation to
% sea-water depth [m].  *(see in-code note at bottom of function)
%
% According to Sebastien Bonnieux the relevant conversion factor to go
% from counts to Pa for the third-generation MERMAID floats
% manufactured by Osean is division by 170176,
%
% COUNTS2PRESSURE assumes a pressure-to-water-depth conversion of
%
%       1 m = 0.101 bar (1.01 dbar) = 1.01e4 Pa
%
% as is done in the MERMAID manual.
%
% Input:
% counts    The raw amplitude(s) output by MERMAID
%               (accepts multiscale cell arrays)
%
% Output:
% Pa        Pressure [Pa]
% m         Equivalent change in sea-water depth [m]
%
% In Ex1 we see a reading of -5e7 counts is equivalent to a drop in
% pressure of roughly 294 Pa, or equivalently, an ascent of (depth is
% negative) of about 29 mm.
%
% Ex1: (MERMAID signal -5e7 counts)
%   [Pa, m] = COUNTS2PRESSURE(-5e7)
%
% Before running Ex2 first run the example in writechangepoint.m.
% CP.outputs.da are the subspace projections of the MERMAID seismogram
% at 5 wavelet scales.
%
% Ex2: (Estimated pressure at every sample at every scale)
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example/changepoints';
%    [CP, filename] = getcp(sac, diro);
%    [Pa, m] = COUNTS2PRESSURE(CP.outputs.da)
%
% See also: pressure2depth.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 27-Jun-2019, Version 2017b

%% Recursive.
if iscell(counts)
    for j = 1:length(counts)
        [Pa{j}, m{j}] = counts2pressure(counts{j});

    end

    %% Recurisve.
    return

end

% Main.
for i = 1:length(counts)
    Pa(i) = counts(i) / 170176;
    m(i) = pressure2depth(Pa(i), 'Pa');

end

% *I.e., the float ascending or descending, or equivalently, the float
% remaining stationary as the ground moves down or up (and thus height
% of the water column above the float goes down or up).
%
% Depending on your reference frame:
% Float moves up relative to ground -> pressure drops -> negative counts
% Float moves up relative to ground == ground moves down relative to float
%
% Float moves down relative to ground -> pressure increases -> positive counts
% Float moves down relative to ground == ground moves up relative to float
%
% Of course MERMAID signals are most usually travelling pressure waves
% so the above are purely a theoretical view of what is happening
% assuming an incompressible fluid, which seawater is not. Such a
% thought experiment may apply in other cases, however, e.g., rising
% gas bubbles literally pushing the float toward the surface.
