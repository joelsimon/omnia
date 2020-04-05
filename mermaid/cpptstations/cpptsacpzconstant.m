function [CONSTANT1, CONSTANT2] = cpptsacpzconstant
% [CONSTANT1, CONSTANT2] = CPPTSACPZCONSTANT
%
% Returns the displacement SACPZ CONSTANT for six stations in the Reseay
% Sismique Polynesien (RSP) network.
%
% Output:
% CONSTANT1   Displacement SACPZ CONSTANT corresponding to PAE, TVO
% CONSTANT2   Displacement SACPZ CONSTANT corresponding to PMOR, VAH, TBI, RKT
%
% See also: sacpzconstant.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Apr-2020, Version 2017b on MACI64

%% Relevant bits of original email.
%%______________________________________________________________________________________%%
% SUBJECT: Polynesian seismic data
% SENT: Fri 24-Jan-2020
%
% Hi Joel,
%
% Here are the links for other seismic data.
%
% Sensitivity :
%
% 0.5236 nm/s/LSB  at 1 Hz for PAE, TVO
% 0.212 nm/s/LSB at 1 Hz for PMOR, VAH, TBI, RKT
%
% Response for PAE, TVO, PMOR, VAH, TBI, RKT  (High pass filter at 1 Hz, order 2) :
%
% 2 zeroes : (0;0) (0;0)
%
% 2 poles : (-4.44;-4.44)(-4.44;4.44)
%
% Regards,
%
% Olivier
%%______________________________________________________________________________________%%

%% Frequency of sensitivity.

% The frequency of sensitivity is always quoted in Hz.
fs_Hz = 1;
fs_rad = 2*pi*fs_Hz;

%% Poles and zeros (the same for all stations stations).

% They were provided to me in terms of velocity.
Z_vel = [0+0i ...
         0+0i];
P_vel = [-4.44-4.44i ...
         -4.44+4.44i];

% To convert to displacement, add one zero. The poles are unchanged.
Z_disp = [0+0i ...
          0+0i ...
          0+0i];
P_disp = [-4.44-4.44i ...
          -4.44+4.44i];

%% Sensitivities (Sd in SEED parlance).

% NB, the equality of [nm/s/lsb]^-1 = [(nm/s)/lsb]^-1 = counts/(nm/s) was
% verified by Olivier Hyvernaud 22-Feb-2020, pers. comm.
%
% We must convert Sd from <physical_unit>/count --> count/<physical_unit> (the
% convention in the SEED manual, and how SACPZ, RESP, and StationXML files are
% delivered from IRIS).  Next we must convert from velocity to displacement,
% such that a TRANSFER to NONE in SAC produces a displacement
% seismogram. Finally, in keeping with SEED standard of SI units, we must
% convert them from nanometers to meters.

% I will refer to stations PAE, TVO as group 1 and all others as group 2.  These
% are the sensitivities (gains) as provided in nm/s/LSB.
Sd1_vel = 0.5236;
Sd2_vel = 0.212;

% Convert from nm/s/LSB to counts/(m/s).
Sd1_vel = Sd1_vel^-1 * 1e9;
Sd2_vel = Sd2_vel^-1 * 1e9;

% Convert from velocity sensitivities to displacement sensitivities.  This
% requires multiplying by frequency of sensitivity in rad/s because the
% sensitivity (while quoted in Hz) was computed in rad/s.
Sd1_disp = Sd1_vel*fs_rad;
Sd2_disp = Sd2_vel*fs_rad;

% Finally, compute the constants.
CONSTANT1 = sacpzconstant(Sd1_disp, fs_Hz, P_disp, Z_disp);
CONSTANT2 = sacpzconstant(Sd2_disp, fs_Hz, P_disp, Z_disp);
