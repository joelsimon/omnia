function A0 = transfunc(sensortype, fs)
% A0 = TRANSFUNC(sensortype, fs)
%
% Plot the (ungained) transfer function and return A0 normalization factor.
% TRANSFUNC generates instrument response diagrams (Bode plots) of various
% seismic instruments.  It takes a sensor name, where the final lowercase letter
% identifies its corresponding (hardcoded) poles and zeros are in reference to
% the velocity ('PAEv') or displacement ('PAEd') response. See the examples for
% how to convert between the two, and sacpzconstant.m to compute the SACPZ
% CONSTANT.
%
% Input:
% sensortype     Sensor name, e.g., 'PAEv' from Reseau Sismique Polynesien
%                    (velocity; see internally for all examples)
% fs             Frequency of sensitivity (Hz)
%
% Output:
% A0             A0 normalization factor, the inverse of the transfer function
%                   evaluated at the frequency of sensitivity
%
% NB, from "IRIS: the RESP Format" at https://ds.iris.edu/ds/nodes/dmc/data/formats/resp/
%          A0_disp = A0_vel / (2 * pi * fs)
%
% And to convert between a velocity (M/S) pole-zero to a displacement
% (M) or, acceleration to velocity, just add an extra set of zeros.
% In the examples below PAE and AFI poles and zeros were both supplied
% to me in VELOCITY (the former, in an email from Olivier Hyvernaud,
% the latter in a RESP file), and to convert them to displacement I
% simply added one extra zero, here.
%
% In the following examples, sensitivity_vel is Sd ("sensitivity or gain
% constant at fs"), for a set of velocity poles and zeros (SEED manual v2.4
% pg. 157), and sensitivity_disp Sd for a displacement set of poles and zeros.
%
% Ex1: (computing the CONSTANT for a displacement SACPZ file)
%    figure
%    fs = 1; % Hz, supplied by Olivier Hyvernaud
%    A0v = TRANSFUNC('PAEv', fs)
%    figure
%    A0d = TRANSFUNC('PAEd', fs)
%    A0d - (A0v/(2*pi*1))  % these should equal
%    % sensitivity_vel = 0.5236 nm/s/LSB (==(nm/s)/COUNTS), supplied by
%    % Olivier Hyvernaud, therefore take inverse and mul by 1e9 to convert to meters
%    sensitivity_vel = (1/0.5236) * 1e9
%    CONSTd = A0d * sensitivity_vel * 2 * pi * fs
%
% Ex2: (comparing AFI_old.pz, AFI_new.pz, AFI_resp.pz CONSTANT; i.e.,
%       comparing SACPZ (displacement) with RESP (velocity), see AFI.resp in
%       $MERMAID/events/nearbystations/pz/examples/RESP_example/)
%    % In the RESP file (in velocity, M/S) ...
%    sensitivity_vel = 2.44780E+09;
%    fs = 0.02;
%    figure
%    A0v = TRANSFUNC('AFIv', fs)
%    figure
%    A0d = TRANSFUNC('AFId', fs)
%    A0d - (A0v/(2*pi*0.02))
%    A0_resp_vel = +4.56729E+01;
%    % Which does indeed equal what we found here, within numerical error.
%    A0v - A0_resp_vel
%    % And the CONSTANT in the associated SACPZ file (in displacement, M).
%    CONST_sacpz_disp = 1.117977e+11;
%    % Which should equal what we found here
%    CONSTd = A0d * sensitivity_vel * 2 * pi * fs
%    CONSTv = A0v * sensitivity_vel
%    % The CONSTANT value from RESP (A0_resp_vel * sensitivity) = 1.1180e+11 (supplied)
%    % The CONSTANT in AFI_old.pz = 1.117977e+11 (supplied)
%    % The CONSTANT in AFI_new.pz = 1.117981e+11 (supplied)
%    % And CONSTd and CONSTv = 1.1180e+11 (derived, using RESP poles and zeros)
%
% Ex3: (converting a velocity RESP file to a DISPLACEMENT pole-zero file, see
%       https://ds.iris.edu/ds/support/faq/24/what-are-the-fields-in-a-resp-file/)
%    figure
%    sensitivity_vel = 9.630000E+08;
%    fs = 0.02;
%    A0_vel = TRANSFUNC('RESPv', fs)
%    figure
%    A0_disp = TRANSFUNC('RESPd', fs)
%    % CONST_disp = A0_disp * sensitivity_disp
%    CONST_disp = A0_disp * sensitivity_vel * 2 * pi *  fs
%    CONST_vel = A0_vel * sensitivity_vel
%    CONST_disp - CONST_vel      % equal, within numerical error
%
% Ex4: (using a VELOCITY StationXML file to compute the DISPLACEMENT SACPZ CONSTANT
%      see internal cases 'R06CDv' and 'R06CDd' for full derivation and web links)
%    %% Reading StationXML file (M/S; 4 zeros) --
%    % <NormalizationFrequency>5</NormalizationFrequency>
%    figure
%    fs = 5;
%    A0v = TRANSFUNC('R06CDv', 5)
%    % This should equal <NormalizationFactor>0.00149803</NormalizationFactor>
%    sprintf('NormalizationFactor = %.8f', A0v)
%    % And the CONSTANTv is A0v * sensitivity [COUNTS/(m/s)]
%    % <Value>469087000</Value>
%    sensitivity_vel = 469087000;
%    CONSTANTv = A0v * sensitivity_vel
%    % CONSTANTv is the CONSTANT we would put at the bottom of a SACPZ
%    % file with 4 ZEROS s.t. a SAC TRANSFER to NONE would actually
%    % produce a velocity seismogram, and the same CONSTANT we would put
%    % at the bottom of a SACPZ file with 5 ZEROS s.t. SAC TRANSFER to
%    % NONE would produce the correct displacement seismogram.
%
%    %% Reading SACPZ file (M; 5 zeros)
%    % I have already shown multiple times CONSTANTd = CONSTANTv,
%    % but to beat the dead horse...
%    figure
%    A0d = TRANSFUNC('R06CDd', 5)
%    CONSTANTd = A0d * sensitivity_vel * 2 * pi * fs
%    CONSTANTv - CONSTANTd
%    % The CONSTANT in the SACPZ file equals 7.027064e+05
%    sprintf('%.6e', CONSTANTd)
%    % Which is different simply due to precision issues; if you use the numbers above
%    % you get it exactly: sprintf('%.6e', 0.00149803 * 469087000.0),
%    % the difference is ~1/10,000 of 1%: ((CONSTANTd - 7.027064e+05)/7.027064e+05)*100
%
% Ex5: (verify A0 normalization factor matches that of SEED manual pg. 167)
%    % Eq. 26, SEED manual v2.4: A0 = 8.79640
%    transfunc('SEED', 1)
%
% NB, in the third example, what I call the CONST_vel is the SACPZ
% CONSTANT that would go at the very bottom of a VELOCITY (M/S) SACPZ
% file, (which is not the SEED standard which states SACPZ files are
% in terms of DISPLACEMENT, M), such that
%
%    transfer from polezero subtype SACPZ_vel.pz to none ==
%    transfer from polezero subtype SACPZ_disp.pz to vel
%
% I.e., what I call the CONSTANT_vel ~= A0_vel, that latter of which
% the webpage above loosely terms as the "poles-and-zeros constant for
% the velocity poles-zeros in the RESP file."  All this is to say,
% what is termed a "constant" in SACPZ and RESP files are not the same
% thing.
%
% For more, see $MERMAID/events/cpptstations/pz/examples/PZ_vel_vs_PZ_disp/
%
% This code is heavily-modified from an original function,
% 'plot_transfer_function.m', written by Umair bin Waheed.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 05-Apr-2020, Version 2017b on MACI64

% Hardcoded poles and zeros.
switch sensortype
    case 'RESPv' % Velocity
    Z = [0+0i ...
         0+0i];
    P = [-1.234000E-02+1.234000E-02i ...
         -1.234000E-02-1.234000E-02i ...
         -3.918000E+01+4.912000E+01i ...
         -3.918000E+01-4.912000E+01i];
    typestr='Velocity';

  case 'RESPd' % Displacement
    Z = [0+0i ...
         0+0i ... % extra zero
         0+0i];
    P = [-1.234000E-02+1.234000E-02i ...
         -1.234000E-02-1.234000E-02i ...
         -3.918000E+01+4.912000E+01i ...
         -3.918000E+01-4.912000E+01i];
    typestr='Displacement';

  case {'PAEv','TVOv','PMORv','VAHv','TBIv','RKTv'} % Velocity
    Z=[0+0i...
       0+0i];
    P=[-4.44-4.44i ...
       -4.44+4.44i];
    typestr='Velocity';

  case {'PAEd','TVOd','PMORd','VAHd','TBId','RKTd'} % Displacement
    Z=[0+0i ...
       0+0i ... % extra zero
       0+0i];
    P=[-4.44-4.44i ...
       -4.44+4.44i];
    typestr='Displacement';

  case 'PPTF'
    Z = [0+0i ...
         0+0i ...
         0+0i];
    P =  [-1.229700e-02+1.206000e-02i ...
          -1.229700e-02-1.206000e-02i ...
          -3.190240e+01+6.878330e+01i ...
          -3.190240e+01-6.878330e+01i];
    typestr = 'Displacement'

  case 'AFIv' % Velocity
    % Directly from
    % $MERMAID/events/nearbystations/pz/examples/RESP_example/AFI.RESP
    Z = [+0.00000E+00+0.00000E+00i ...
         +0.00000E+00+0.00000E+00i ...
         -9.42478E+00+0.00000E+00i ...
         -6.28319E+02+0.00000E+00i ...
         -5.65487E+02-9.79452E+02i ...
         -5.65487E+02+9.79452E+02i];
    P = [-3.72833E-02-3.67000E-02i ...
         -3.72833E-02+3.67000E-02i ...
         -9.73894E+00+0.00000E+00i ...
         -2.19911E+02-1.38230E+02i ...
         -2.19911E+02+1.38230E+02i ...
         -2.19911E+02-6.84867E+02i ...
         -2.19911E+02+6.84867E+02i];
    typestr = 'Velocity';

  case 'AFId' % Displacement
    % Directly from
    % $MERMAID/events/nearbystations/pz/examples/RESP_example/AFI.RESP,
    % with an extra zero
    Z = [+0.00000E+00+0.00000E+00i ...
         +0.00000E+00+0.00000E+00i ...
         +0.00000E+00+0.00000E+00i ...  % (one extra zero)
         -9.42478E+00+0.00000E+00i ...
         -6.28319E+02+0.00000E+00i ...
         -5.65487E+02-9.79452E+02i ...
         -5.65487E+02+9.79452E+02i];
    P = [-3.72833E-02-3.67000E-02i ...
         -3.72833E-02+3.67000E-02i ...
         -9.73894E+00+0.00000E+00i ...
         -2.19911E+02-1.38230E+02i ...
         -2.19911E+02+1.38230E+02i ...
         -2.19911E+02-6.84867E+02i ...
         -2.19911E+02+6.84867E+02i];
    typestr = 'Velocity';

  case 'ISOLAv' % $MERMAID/events/nearbystations/pz/notes/ISOLA.doc
    Z = [0.0+0.0i ...
         0.0+0.0i ...
         51.5+0.0i];
    P = [-272+218i ...
         -272-218i ...
         56.5+0i ...
         -0.1111+0.1111i ...
         -0.1111-0.1111i];
    typestr = 'Velocity';

  case 'R06CDv'
    % Station XML in velocity (M/S)
    % https://fdsnws.raspberryshakedata.com/fdsnws/station/1/query?network=AM&station=R06CD&location=00&channel=*Z&level=response&start=2019-03-15&end=2019-03-15format=xml
    % Normalization frequency: 5 Hz (fs)
    % Normalization factor: (A0v)
    % Look at <Stage number="1"> (<PzTransferFunctionType>LAPLACE (RADIANS/SECOND)</PzTransferFunctionType>)
    Z = [-675.214+0i ...  % <Zero number="3">
         0+0i ...         % <Zero number="4">
         0+0i ...         % <Zero number="5">
         0+0i];           % <Pole number="6">

    P = [-4.21019+0i ...  % <Pole number="0">
         -2.33332+0i ...  % <Pole number="1">
         -1.29888+0i];    % <Pole number="2">
    typestr = 'Velocity';

  case 'R06CDd'
    % Compared to R06CDv, add one zero to convert to displacement.
    % Look at AM.R06CD.pz, which was converted from STATION XML to SACPZ with xml2pz.py.
    Z = [-675.214+0i ...
         0+0i ...
         0+0i ...
         0+0i ...
         0+0i];
    P = [-4.21019+0i ...
         -2.33332+0i ...
         -1.29888+0i];
    typestr = 'Displacement';

  case 'SEED'
    % Equation (26), SEED manual v2.4, pg. 167.
    Z = [0+0i];
    P = [-4.3982+4.4871i ...
         -4.3982-4.4871i];
    typestr = 'Acceleration';

  otherwise
  error('Specify valid sensor type')

end

% Convert from Laplace Transform (zero-pole) to transfer function (numerator and
% denominator coefficient sets).  SAC pole-zero examples all use Laplace
% transform variants.
[b, a] = zp2tf(Z(:), P(:), 1);

% Create log frequency axis.
fminlog = -2;
fmaxlog = +2;

% NB: we do not have to multiply w by i (complex) because freqs.m does that for
% us, internally -- "The function evaluates the ratio of Laplace transform
% polynomials along the imaginary axis at the frequency points s = jw."  (see
% line 79).  We do have to convert Hz to rad/s.
w = 2*pi*logspace(fminlog, fmaxlog, 1001);

% Evaluate the frequency response -- again, freqs.m expects real-valued
% frequencies in rad/s.
Hp = freqs(b, a, w);

% Repeat process above for a set of frequencies centered on the sensitivity
% frequency, so we can quote the A0 normalization factor, which is defined as
% the inverse of the transfer function evaluated at the sensitivity frequency.
% I do no have to call freqs.m twice, obviously -- this is done to make the
% evaluation at the frequency of sensitivity explicit.
w_fs =  2*pi*fs;
test_fs  =  [w_fs-pi, w_fs, w_fs+pi];
Hp_fs = freqs(b, a, test_fs);
Hp_fs = Hp_fs(2);

% The normalization factor is the inverse of the (ungained!, K = 1) transfer
% function evaluated at the sensitivity frequency.
A0  =  1/abs(Hp_fs);

% Plot system response

% Magnitude.
ah(1) = subplot(2, 1, 1);
pp(1) = loglog(w/(2*pi), abs(Hp));
xl(1) = xlabel('Frequency (Hz)');
yl(1) = ylabel(sprintf('%s magnitude response', typestr));
t = title(sprintf('%s transfer function', sensortype));

% Phase.
ah(2) = subplot(2, 1, 2);
pp(2) = semilogx(w/(2*pi), phase(Hp)/pi*180);
xl(2) = xlabel('Frequency (Hz)');
yl(2) = ylabel(sprintf('%s phase response (degrees)', typestr));

% Cosmetics.
set(ah, 'xgrid', 'on', 'ygrid', 'on')
set(ah, 'xlim', 10.^[fminlog fmaxlog])
set(ah, 'xtick', 10.^[fminlog:fmaxlog])
set(pp(1), 'Color',  'b', 'LineWidth', 2)
set(pp(2), 'Color', 'r', 'LineWidth', 2)
longticks(ah, 2)
