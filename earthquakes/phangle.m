function [phid, phir] = phangle(rayParam, phaseName, mod)
% [phid, phir] = PHANGLE(rayParam, phaseName, mod)
%
% PHANGLE computes the incidence angle relative to the normal of an
% incoming seismic wave at the surface of the Earth (r=6371 km) given
% a spherical Earth ray parameter in units of [deg/s],
%
%                 rayParam = 6371*sin(phid)/v,
%
% as is returned from taupTime.
%
% Inputs:
% rayParam    Spherical ray parameter in deg / s (from taupTime.m) 
% phaseName   Phase name (e.g., 'P' or 'SKIKS')
% mod         Either 'ak135', 'iasp91', or 'prem' (def: 'ak135')
%
% Outputs:
% phid        Incidence angle of incoming P wave in degrees from normal
% phir        Incidence angle of incoming P wave in radians from normal
%
% Ex: (compare with output of command line taup_time)
%--> MATLAB:         
%    tt = taupTime('ak135', 664, 'P,PP,PKiKP,SKKKKS', 'deg', 57.889);
%    for i = 1:length(tt);
%        phid(i) = PHANGLE(tt(i).rayParam, tt(i).phaseName, 'ak135');
%    end
%    [{tt.phaseName}' {tt.incidenceAngle}'] = 
%        {'P'     }    {[20.4531]}
%        {'PP'    }    {[27.1780]}
%        {'PKiKP' }    {[ 3.6231]}
%        {'SKKKKS'}    {[ 8.8721]}
%        {'SKKKKS'}    {[ 6.1915}]
%
%--> Command line: 
%    $ taup_time -h 664  -ph P,PP,PKiKP,SKKKKS -deg 57.889 -mod ak135
%
% Model: ak135
% Distance   Depth   Phase    Travel    Ray Param  Takeoff  Incident  Purist    Purist
%   (deg)     (km)   Name     Time (s)  p (s/deg)   (deg)    (deg)   Distance   Name 
% ------------------------------------------------------------------------------------
%    57.89   664.0   P         531.17     6.699     46.59    20.45    57.89   = P     
%    57.89   664.0   PP        670.91     8.757     71.72    27.18    57.89   = PP    
%    57.89   664.0   PKiKP     954.89     1.211      7.55     3.62    57.89   = PKiKP 
%    57.89   664.0   SKKKKS   2660.58     4.957     17.28     8.87   302.11   = SKKKKS
%    57.89   664.0   SKKKKS   3146.89     3.466     11.99     6.19   417.89   = SKKKKS
%
%
% See also: MatTaup
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Aug-2018, Version 2017b

% Default model.
defval('mod', 'ak135')

r = 6371;  % km

% All vp, vs given below are in [km/s]. 
switch lower(mod)
  case 'ak135'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/ak135.tvel
    vp = 5.8;  
    vs = 3.46; 
    
  case 'iasp91'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/iasp91.taup
    vp = 5.8;  
    vs = 3.36; 

  case 'prem'
    % $OMNIA/notmycode/MatTaup/lib/matTaup.jar --> edu/sc/seis/TauP/StdModels/prem.nd
    % (TauP extends the "crust" layer to the surface, there is no "ocean").
    vp = 5.8;  
    vs = 3.2; 

  otherwise
    error('Invalid model name.  Must be either ''ak135'', ''iasp91'', or ''prem''.')

end
    
% Determine what velocity to use.
if strcmp(lower(phaseName(1)), 'p')
    v = vp;
elseif strcmp(lower(phaseName(1)), 's')
    v = vs;
else
    error('Invalid phase name.  Must begin with either ''P'' or ''S''.')
end

% Main.
phid = asind(rayParam*v/6371);    % degrees
phir = phid * pi/180;             % radians
