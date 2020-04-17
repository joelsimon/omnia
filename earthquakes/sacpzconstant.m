function [CONSTANT, A0] = sacpzconstant(SD, fs, P, Z)
% [CONSTANT, A0] = SACPZCONSTANT(SD, fs, P, Z)
%
% SACPZCONSTANT returns the CONSTANT and A0 normalization factor for a
% displacement SACPZ file.
%
% Input:
% SD          Gain constant or sensitivity, true at fs [counts/m]
% fs          Frequency at which the gain constant is true [Hz]
% P           Complex poles of the transfer function [rad/s]
% Z           Complex zeros of transfer function [rad/s]
%
% Output:
% CONSTANT    SACPZ file CONSTANT (TRANSFER to NONE = meters)
% A0          A0 normalization factor at fs
%
% In the parlance of the SEED Manual v2.4, SD (uppercase "D;" my notation)
% corresponds to the combined sensitivity considering all stages, and Sd
% (lowercase "d"; their notation) is the sensitivity at a single stage, e.g.,
% the analog stage. In the example on pg. 166, the first stage is the
% seismometer [V/(m/s^2)], and the second stage is the digitizer [counts/V].
% These two sensitivities are multiplied in stage 0 to compute the total
% sensitivity (SD) of the system (we are ignoring other digital stages (3+; FIR
% filters etc.), which also contribute to the stage 0 sensitivity, but
% negligibly).  Ultimately, the combined sensitivity, SD, of the system is
% quoted in units like [counts/(m/s^2)], though here it must be input in terms
% of counts/m.
%
% Therefore, using eq. (6) on pg. 159, ignoring frequency effects after the
% analog stage, and substituting the total sensitivity at SD for the
% analog-stage sensitivity, Sd, "...at any frequency f (in Hz) the response is,"
%
%                G(f) =  SD * A0 * Hp(s)
%                     = CONSTANT * Hp(s), (author's interpretation)
%
% where (pg. 158), "...Hp(s) represents the transfer function ratio of
% polynomials specified by their roots," the roots being the poles and zeros
% when s = 2pi*i*f rad/s (f in Hz).
%
% While I have never seen it explicitly stated in either the SEED or SAC manuals
% that the SACPZ CONSTANT = SD * A0, I have...
%
% (1) Seen that statement in ObsPy (1.2.0) source code --
%     https://docs.obspy.org/_modules/obspy/io/sac/sacpz.html
% (2) Seen that statement on the IRIS' help pages --
%     https://ds.iris.edu/ds/support/faq/24/what-are-the-fields-in-a-resp-file/
% (3) Verified that relation through pers. comm. with Olivier Hyvernaud
% (4) Concluded it must be so given the definition of the G(f)
%
% SACPZCONSTANT assumes the input poles and zeros correspond to a a "Transfer
% function type: A", i.e., "Laplace transform analog response, in rad/sec"
% (pg. 53).  Further, the transfer function must be described by its roots
% (poles, 'P', and zeros, 'Z'), not the the coefficients of its numerators and
% denominators.  This is the SEED "preferred" standard (pg. 159), and the only
% way I have ever seen these data represented (they are called "Pole-Zero
% files," not "transfer-function coefficient files" for a reason.  Finally, 'SD'
% is sensitivity at 'fs' Hz, and must be given in counts/m to conform to the
% SEED standard of SI units (meters, not nanometers), and the SAC standard that
% a TRANSFER to NONE results in a displacement seismogram.  Note these conflict:
% in SAC a TRANSFER to NONE assumes displacement units of nanometers.  Here we
% prioritize SEED standards.
%
% All this is to say that if you get any random RESP or StationXML file, those
% values are more than likely already in the UNITS required as input here to
% result in a DISPLACEMENT poles and zeros file, however, their VALUES may need
% to be adjusted to move from, e.g., velocity to displacement (add one zero;
% multiply SD by 2pi*fs).
%
% Ex:( velocity RESP file to displacement SACPZ file, following the example of:  )
%    ( https://ds.iris.edu/ds/support/faq/24/what-are-the-fields-in-a-resp-file/ )
%    SD_vel =  9.630000E+08; % counts/(m/s)
%    fs = 0.02; % Hz
%    P_vel = [-0.0123+0.0123i, -0.0123-0.0123i, -39.1800+49.1200i, -39.1800-49.1200i];
%    Z_vel = [0, 0];
%    % Convert SD from vel. to disp, by multiplication with 2pi*fs (SD computed in rad/s)
%    SD_disp = SD_vel*2*pi*fs; % counts/m
%    % Convert PZ from vel. to disp. by addition of one zero (poles unchanged)
%    Z_disp = [Z_vel 0];
%    P_disp = P_vel;
%    [CONSTANT, A0] = SACPZCONSTANT(SD_disp, fs, P_disp, Z_disp);
%    fprintf('Displacement SACPZ CONSTANT and A0 given by IRIS: 3.802483e+12, 31421.7\n')
%    fprintf('Displacement SACPZ CONSTANT and A0 computed here: %.6e, %.1f\n', CONSTANT, A0)
%    fprintf('The CONSTANT differs by %.4e%s\n', ...
%             abs((CONSTANT-3.802483e+12)/3.802483e+12)*100, '%')
%
% For myriad verifications,
% see also: transfunc.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Convert transfer function from pole-zero representation to
% numerator-denominator coefficient sets.
[b, a] = zp2tf(Z(:), P(:), 1);

% Convert sensitivity frequency from Hz to rad/s.
fs = 2*pi*fs;

% Compute the complex frequency response of the transfer function, which
% requires at least two frequencies as input. Don't multiply 'w' by complex 'i'
% (or 'j') because freqs.m does that internally with the frequency vector.
w = [fs-pi, fs, fs+pi];
Hp = freqs(b, a, w);

% Return the frequency response evaluated at the sensitivity frequency.
Hp_fs = Hp(2);

% The normalization factor is the modulus of the transfer function evaluated at
% the sensitivity frequency, and the SACPZ CONSTANT is that factor multiplied by
% the sensitivity.
A0 =  1/abs(Hp_fs);
CONSTANT = A0*SD;
