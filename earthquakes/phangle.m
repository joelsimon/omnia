function [tdeg, trad, ideg, irad] = phangle(rayParam, phaseName, mod, depth)
% [tdeg, trad, ideg, irad] = PHANGLE(rayParam, phaseName, mod)
%
% PHANGLE computes the incidence, angle, relative to the normal, of an
% incoming seismic phase at the surface of the Earth (r = 6371 km),
% given a spherical Earth ray parameter in units of [deg/s], i.e.,
%
%           rayParam = 6371 * sind(theta) / v,
%
% as is returned from taupTime.
%
% Input:
% rayParam    Spherical ray parameter in [deg/s] 
%                 (e.g, from taupTime.m) 
% phaseName   Phase name (e.g., 'P' or 'SKIKS')
% mod         Either 'ak135', 'iasp91', or 'prem'
% depth       Event depth*
%
% Output: 
% tdeg**      Takeoff angle of outgoing phase [deg]
% trad**      Takeoff angle of outgoing phase [rad]
% ideg        Incidence angle of incoming phase [deg]
% irad        Incidence angle of incoming phase [rad]
%
% *currently unused, but required for computation of takeoff angle (wish list)
% **currently not supported (both output NaN)
%
% Ex: (taupTime calls PHANGLE internally)
%--> MATLAB:         
%    tt = taupTime('ak135', 664, 'P,PP,PKiKP,SKKKKS,SKiKKiKP,PKiKKiKS', 'deg', 57.889);
%    [{tt.phaseName}' {tt.incidentDeg}'] = 
%
%        {'P'       }    {[20.4531]}
%        {'PP'      }    {[27.1780]}
%        {'PKiKP'   }    {[ 3.6231]}
%        {'SKiKKiKP'}    {[ 2.2029]}
%        {'PKiKKiKS'}    {[ 1.3177]}
%        {'SKKKKS'  }    {[ 8.8721]}
%        {'SKKKKS'  }    {[ 6.1915]}
%
%--> Command line: 
%    $ taup_time -h 664  -ph P,PP,PKiKP,SKKKKS,SKiKKiKP,PKiKKiKS -deg 57.889 -mod ak135
%    Model: ak135
%    Distance   Depth   Phase      Travel    Ray Param  Takeoff  Incident  Purist    Purist
%      (deg)     (km)   Name       Time (s)  p (s/deg)   (deg)    (deg)   Distance   Name 
%    --------------------------------------------------------------------------------------
%       57.89   664.0   P           531.17     6.699     46.59    20.45    57.89   = P       
%       57.89   664.0   PP          670.91     8.757     71.72    27.18    57.89   = PP      
%       57.89   664.0   PKiKP       954.89     1.211      7.55     3.62    57.89   = PKiKP   
%       57.89   664.0   SKiKKiKP   1572.94     0.737      2.53     2.20    57.89   = SKiKKiKP
%       57.89   664.0   PKiKKiKS   1635.29     0.739      4.60     1.32    57.89   = PKiKKiKS
%       57.89   664.0   SKKKKS     2660.58     4.957     17.28     8.87   302.11   = SKKKKS  
%       57.89   664.0   SKKKKS     3146.89     3.466     11.99     6.19   417.89   = SKKKKS  
%
% See also: MatTaup
%
% JDS: See notebook 1, pp. 55--57; lay+1995 pp. 75, 91--92.
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 20-Mar-2019, Version 2017b

% Wish list:
%
% Takeoff angle.  See discussion at end of function.

% Preliminaries.
ph = lower(purist(phaseName));
r = 6371;  % km

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

% See Taup_Instructions.pdf pg. 17, item 10.  This suffix is generally
% used for surface wave travel-time estimation and thus
% takeoff/incidence angles are not meaningful.
if endsWith(ph, 'kmps', 'IgnoreCase', true)
    tdeg = NaN;
    trad = NaN;
    ideg = NaN;
    irad = NaN;
    warning('No takeoff/incidence angle associated with phase: ''%s''', ph)
    return

end

% All vp, vs given below are in [km/s]. 
switch lower(mod)
  case 'ak135'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/ak135.tvel
    vp = 5.80;  
    vs = 3.46; 
    
  case 'iasp91'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/iasp91.taup
    vp = 5.80;  
    vs = 3.36; 

  case 'prem'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/prem.nd
    % (TauP extends the "crust" layer to the surface, there is no "ocean").
    vp = 5.80;  
    vs = 3.20; 

  otherwise
    error(['Invalid model name: ''%s''\nMust be one of: ''ak135'', ' ...
           '''iasp91'', or ''prem'' (case insensitive)'], mod)

end

% Incidence velocity: last leg of the phase.
switch ph(end) 
  case 'p'
    iv = vp;
    
  case 's'
    iv = vs;

  otherwise
    error(['Invalid phase name: ''%s''\nMust end with either ''P'' ' ...
           'or ''S'' (case insensitive)'], ph)

end
ideg = asind(rayParam * iv / r); % degrees
irad = ideg * pi / 180;         % radians

% Placeholders, for now.
tdeg = NaN;
trad = NaN;

%____________________________________________________________________%

% Takeoff angle requires knowing the velocity at the first leg of the
% phase (ph(1); either 'P' or 'S'), at the given source depth.  From
% TauP_Instructions.pdf pg. 18:
%
% "The model is assumed to be linear between given depths and repeated
% depths are used to represent discontinuities."
%
% Therefore, the velocity at the source depth could determined by
% linearly interpolating between the depths that bracket the requested
% source depth, as read from the .tvel or .nd table.  I am not sure
% what happens at discontinuities -- if it takes the velocity above or
% below at the same depth, but my testing implies it takes the first
% (above) velocity (need to verify this).
%
% Once you have this velocity the computation of the takeoff angle is
% straightforward (the ray parameter is a constant!):

% rz = r - depth;  % Radius at source depth.
% vz = ?           % Velocity at source depth.

% tdeg = asind((rayParam * vz) / rz); % degrees
% trad = tdeg * pi / 180;             % radians
