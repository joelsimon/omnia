function [tadj, theta2] = bathtime(mod, ph, theta1, z_ocean, z_mermaid)
% [tadj, theta2] = BATHTIME(mod, ph, theta1, z_ocean, z_mermaid)
%
% Computes the travel time correction due to bathymetry and the depth
% of MERMAID at the time of recording.  It assumes an acoustic
% velocity of 1500 m/s in water.
%
% BATHTIME timing convention:
% positive tadj: adjusted theoretical arrival at MERMAID late compared to model
% negative tadj: adjusted theoretical arrival at MERMAID early compared to model
%
% Therefore, the corrected travel time at MERMAID is the theoretical
% travel time plus the time difference (adjustment) computed here.
%
%   <Station in water at depth>   <Station on rock at surface>
%   ----------------------------------------------------------
%     1D adjusted travel time   =    1D travel time + tadj
%      1D adjusted residual     =     1D residual - tadj
%
% Input:
% mod        Either 'ak135', 'iasp91', or 'prem' (def: 'ak135')
% ph         Phase names allowed in TauP, e.g., 'P' or 'SKIKS';
%                not 'P''' or 'PcP2' (def: 'p')
% theta1     Incidence angle of ray incident on ocean bottom,
%                0 <= i < 90 [deg] (def: 0)
% z_ocean    Bathymetric depth (must be negative) [m] (def: -4000)*
% z_mermaid  Depth of MERMAID at time of recording
%                (must be negative) [m] (def: -1500)
%
% Output:
% tadj       Time difference between reference model with bathymetry
%                and receiver at depth, and reference model with no bathymetry
%                and receiver at the surface (i.e., normal taupTime)
% theta2     Incidence angle of acoustic wave recorded at MERMAID
%
% *Adjusted down (deeper) to z_mermaid in the case that z_mermaid is
%  deeper than the reported ocean depth, e.g., under assumption that
%  in places the MERMAID-reported depth is more accurate than GEBCO
%  (see Ex2)
%
% Ex1: (P wave incident at seafloor at 0 degrees, in
%       4 km deep ocean recorded by MERMAID at 1.5 km)
%    [tadj, theta2] = BATHTIME('ak135', 'p', 0, -4000, -1500)
%
% Ex2: (MERMAID "deeper" than ocean for P wave incident at 0 degrees;
%       adjust ocean depth and find in this model the P wave would arrive
%       1 s sooner than in ak135)
%    [tadj, theta2] = BATHTIME('ak135', 'p', 0, -5200, -5800)
%
% Ex3: (pathological case: S wave faster in model with bathymetry because
%       incidence angle at seafloor is so high; faster to travel more vertically
%       in water column)
%    [tadj, theta2] = BATHTIME('prem', 's', 89.9, -4000, -1500)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64
% Documented pp. 73-75, 127 2017.2

% Defaults.
defval('mod', 'ak135')
defval('ph', 'p')
defval('theta1', 0)
defval('z_ocean', -4000)
defval('z_mermaid', -1500)

% Sanity.
%__________________________________________________________________________________%
% See Taup_Instructions.pdf pg. 17, item 10.  This suffix is generally
% used for surface wave travel-time estimation.
if endsWith(ph, 'kmps', 'IgnoreCase', true)
    error('input phase must be body wave; surface wave phase given')

end

if z_ocean > 0 || z_mermaid > 0
    error('bathymetric (z_ocean) and MERMAID (z_mermaid) depths must be negative')

end

if z_mermaid < z_ocean
    warning(sprintf(['MERMAID depth (z_mermaid) larger (deeper) than ' ...
                     'ocean depth (z_ocean)\nAdjusting ocean depth ' ...
                     'to MERMAID depth: %.2f m'], z_mermaid))
    z_ocean = z_mermaid;

end

if theta1 < 0 || theta1 >= 90
    error('incidence angle must be between 0 (inclusive) and 90 (exclusive) degrees')

end
%__________________________________________________________________________________%


% Preliminaries: determine the velocity of the last leg of the phase
% s.t. we may use Snel's law to determine the incidence angle of the
% converted acoustic phase in the water column
%__________________________________________________________________________________%
% Ensure phase names in line with what is expected in taupTime.
ph = lower(purist(ph));

% Remove 'diff', 'g', or 'n', suffix, if it exists.  Other prefixes
% ('ab', etc.), are handled by purist.m, above.
%
% N.B.: Other phase IASPEI-approved suffixes also exist (e.g., 'dif'
% in favor of 'diff'; 'pre'; 'PcP2' to mean multiple reflections; 'P''
% (prime); 'Sb', 'S*', etc.  Being that phangle.m is designed to be
% called most often as a subfunction of MatTaup I am only coding for
% phase names acceptable there (e.g., 'PcP2' throws an error and thus
% I am not coding a rule to remove suffixes that are numbers).
%
% See TauP_Instructions.pdf pg. 15 for the relevant suffixes.

if endsWith(ph, 'diff', 'IgnoreCase', true)
    ph = ph(1:end-4);

end

if endsWith(ph, {'g' 'n'}, 'IgnoreCase', true)
    ph = ph(1:end-1);

end

% Identify the incoming (last leg) phase name, which is incident on
% the bottom of the ocean and converts to an acoustic (P) wave in the
% water column
incoming_ray = ph(end);

% All vp, vs given below are in [m/s].  The maximum depth restriction
% is to stay within the top (crustal) layer in each of the respective
% models, s.t. I do not have to multiple refractions/velocity layers
% (also, the ocean is not as deep as the first layer in any of the
% models).
switch lower(mod)
  case 'ak135'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/ak135.tvel
    max_depth = -20e3;
    if z_ocean < max_depth || z_mermaid < max_depth
        error(sprintf('input depths cannot exceed (be deeper than) %i m', max_depth));

    end

    if strcmpi(incoming_ray, 'p')
        v1 = 5800;

    elseif strcmpi(incoming_ray, 's')
        v1 = 3460;

    else
        error(sprintf('unrecognized phase name (''%s'') incident at bottom of ocean', incoming_ray));

    end

  case 'iasp91'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/iasp91.taup
    max_depth = -20e3;
    if z_ocean < max_depth || z_mermaid < max_depth
        error(sprintf('input depths cannot exceed (be deeper than) %i m', max_depth));

    end

    if strcmpi(incoming_ray, 'p')
        v1 = 5800;

    elseif strcmpi(incoming_ray, 's')
        v1 = 3360;

    else
        error(sprintf('uncrecognized phase name incident on bottom of ocean %s m', incoming_ray));

    end

  case 'prem'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/prem.nd
    % (TauP extends the "crust" layer to the surface, there is no "ocean").
    max_depth = -15e3;
    if z_ocean < max_depth || z_mermaid < max_depth
        error(sprintf('input depths cannot exceed (be deeper than) %i m', max_depth));

    end

    if strcmpi(incoming_ray, 'p')
        v1 = 5800;

    elseif strcmpi(incoming_ray, 's')
        v1 = 3200;

    else
        error(sprintf('uncrecognized phase name incident on bottom of ocean %s', incoming_ray));

    end

  otherwise
    error(['invalid model name: ''%s''\nmust be one of: ''ak135'', ' ...
           '''iasp91'', or ''prem'' (case insensitive)'], mod)

end
%__________________________________________________________________________________%


% Finally, trivial lines of code to compute the time adjustment.
%__________________________________________________________________________________%
% Convert depths from negative to positive to make computations more intuitive.
z_ocean = abs(z_ocean);
z_mermaid = abs(z_mermaid);

% Time spent in Earth model to traverse a rock layer of the same depth
% as the ocean (beta is a distance; the hypotenuse of the right
% triangle determined by the depth of the layer and the first
% incidence angle).
beta1 = z_ocean / cosd(theta1);
t1 = beta1 / v1;

% Use Snel's law to compute the incidence angle of the converted phase in the water column.
v2 = 1500;
if z_mermaid ~= z_ocean,
    theta2 = asind((sind(theta1) / v1) * v2);

else
    % If the MERMAID is "at" the ocean floor, the incidence angle is the
    % same as in the rock layer, and the travel time from seafloor to
    % MERMAID is 0 s.
    theta2 = theta1;

end

% Time it takes a P wave to travel from the ocean floor to mermaid.
beta2 = (z_ocean - z_mermaid) / cosd(theta2);
t2 = beta2 / v2;

% Total correction.
tadj = t2 - t1;

%%______________________________________________________________________________________%%

% NB, in the notation of equation 6 of paper??
% * Z_w is z_ocean
% * Z_MER is z_mermaid
%
% The "first" segement here is the rock (standard; no water layer) segment:
% * v_r is v1
% * \theta_r is theta1
%
% The "second" segement here is the adjusted segment with a water layer and
% submerged reciever:
% * v_w is v2
% * \theta_w is theta2
%
% Therefore, as described here:
% tadj = t2 - t1
%      = (z_ocean-z_mermaid)/[v2*cosd(theta2)] - z_ocean/[v1*cosd(theta1)]  % this file
%      = (Z_w-Z_MER)/[v_w*cos(\theta_w)] - z_w/[v_r*cos(\theta_r)]          % Eq. 6
