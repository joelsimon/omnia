function [CONSTANT, A0] = sacpzconstant(Sd, fs, P, Z)
% [CONSTANT, A0] = SACPZCONSTANT(Sd, fs, P, Z)
%
% Return the SACPZ CONSTANT in units of counts/m.
%
% In the parlance of the SEED Manual v2.4 , this corresponds to the gain
% constant for the analog stages.  In the example on pg. 166, the first stage is
% the seismometer [V/(m/s^2)], and the second stage is the digitizer [counts/V].
% These two gains are multiplied in stage 0 to represent the total gain of the
% system (we are ignoring other digital stages (3+; FIR filters etc.), that also
% contribute to the stage 0 gain, but negligibly).  Ultimately, the total gain
% (or "sensitivity," Sd) of the analog system is quoted in units like
% [counts/(m/s^2)], though here it must be in input in terms of counts/m.
%
% Using, eq. (6) pg. 159, "...at any frequency f (in Hz) the response is:"
%
%                G(f) =  Sd * A0 * Hp(s)
%                     = CONSTANT * Hp(s)  (author's interpretation)
%
% And pg. 158, "...Hp(s) represents the transfer function ratio of polynomials
% specified by their roots," the roots being the poles and zeros.
%
% While I have never seen it explicitly stated in either the SEED or SAC manuals
% that the SACPZ CONSTANT = Sd * A0, I have seen that statement in,
%
% (1) ObsPy (1.2.0) source code:  https://docs.obspy.org/_modules/obspy/io/sac/sacpz.html
% (2) IRIS' help pages:
%     https://ds.iris.edu/ds/support/faq/24/what-are-the-fields-in-a-resp-file/
% (3) Verified through personal communication with Olivier Hyvernaud at Reseau
%     Sismique Polynesien
% (4) Finally, it only makes sense given the definition of the gain, G(f)
%
% SACPZCONSTANT assumes the input poles and zeros correspond to a a "Transfer
% function type: A", i.e., "Laplace transform analog response, in rad/sec"
% (pg. 53).  Further, the transfer function must be described by its roots
% (poles, 'P', and zeros, 'Z'), not the the coefficients of its numerators and
% denominators.  This is the SEED "preferred" standard (pg. 159), and the only
% way I have ever seen these data represented (they are called "Pole-Zero
% files," not "transfer-function coefficient files" for a reason.  Finally, 'Sd'
% is sensitivity at 'fs' Hz, and must be given in counts/m to conform to the
% SEED standard of SI units (meters, not nanometers), and the SAC standard that
% a TRANSFER to NONE results in a displacement seismogram.  Note these conflict:
% SAC standard transfers to NONE assume units are in nanometers.  We prioritize
% SEED standards here.
%
% All this is to say that if you get any random RESP or STATIONxml file, those
% values are more than likely already in the UNITS required as input here to
% result in a DISPLACEMENT poles and zeros file, however, their VALUES may need
% to be adjusted to move from, e.g., velocity to displacement (add one zero;
% multiply Sd by 2pi*fs).
%
% Ex: (velocity RESP file to displacement SACPZ, from
%      https://ds.iris.edu/ds/support/faq/24/what-are-the-fields-in-a-resp-file/)
%    Sd_vel =  9.630000E+08; % counts/(m/s)
%    fs = 0.02; % Hz
%    P_vel = [-0.0123+0.0123i, -0.0123-0.0123i, -39.1800+49.1200i, -39.1800-49.1200i];
%    Z_vel = [0, 0];
%    % Convert Sd from vel. to disp, by multiplication with 2pi*fs (Sd computed in rad/s)
%    Sd_disp = Sd_vel*2*pi*fs; % counts/m
%    % Convert PZ from vel. to disp. by addition of one zero (poles unchanged)
%    Z_disp = [Z_vel 0];
%    P_disp = P_vel;
%    [CONSTANT, A0] = SACPZCONSTANT(Sd_disp, fs, P_disp, Z_disp);
%    fprintf('Displacement SACPZ CONSTANT and A0 given by IRIS: 3.802483e+12, 31421.7\n')
%    fprintf('Displacement SACPZ CONSTANT and A0 computed here: %.6e, %.1f\n', CONSTANT, A0)
%    fprintf('The CONSTANT differs by %.4e%s\n', abs((CONSTANT-3.802483e+12)/3.802483e+12)*100, '%')
%
% For myriad verifications,
% see also: transfunc.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Apr-2020, Version 2017b on MACI64

% Convert from Laplace Transform (zero-pole) to transfer function (numerator and
% denominator coefficient sets).
[b, a] = zp2tf(Z(:), P(:), 1);

% Convert sensitivity frequency from Hz to rad/s.
fs = 2*pi*fs;

% Compute the complex frequency response of the transfer function, which
% requires at least two frequencies as input, so supply three with the
% sensitivity frequency of interest in the middle.  We don't have to multiply
% 'w' by complex 'i' (or 'j') because freqs.m takes care of that for us.
w = [fs-pi, fs, fs+pi];
Hp = freqs(b, a, w);

% Return the frequency response evaluated at the sensitivity frequency.
Hp_fs = Hp(2);

% The normalization factor is the modulus of the transfer function evaluated at
% the sensitivity frequency, and the SACPZ CONSTANT is that factor multiplied by
% the sensitivity.
A0 =  1/abs(Hp_fs);
CONSTANT = A0*Sd;
