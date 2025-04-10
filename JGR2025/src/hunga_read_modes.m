function [depth, amp, stdp, stamp, maxdepth, maxamp] = hunga_read_modes(kstnm, mtype, freq, plt)
% [depth, amp, stdp, stamp, maxdepth, maxamp] = ...
%     HUNGA_READ_MODES(kstnm, mtype, freq, plt)
%
% Return eigenfunction (mode) whose values are LITERALLY proportional to RMS
% pressure (amplitude; sound pressure level) of the signal, not RMS^2 (amplitude
% squared; sound intensity).
%
% Not all mytpes available for all recievers; some local ocean-depths only
% relevant for a few (e.g., IMS).
%
% Input:
% kstnm       Five character station name
% mtype       Mode type/boundary conditions -
%              1: average_ocdp_PREM
%              2: local_ocdp_PREM
%              3: local_ocdp_PREMVpRhoVs1
%              4: local_ocdp_PREMVpRhoVs2
%              5: local_ocdp_Vp3Rho2pt5Vs0
%              6: local_ocdp_Vp4Rho2Vs2
%              7: local_ocdp_Vp4Rho3Vs0
% freq        Frequency of mode, one of 2.5, 5.0, 7.5, or 10 [Hz]
% plt         true to plot (def: false)
%
% Output:
% depth      Ocean depth in meters positive down
% amp        Value of eigenfunction at depth
% stdp       Station depth in meters positive down
% stamp      Value of eigenfunction at station depth
% maxdepth   Depth in meters positive down where eigenfunction is maximum
% maxamp     Maximum value of eigenfunction
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Defaults.
defval('plt', false)

% Identify modes/ subdirectory.
switch mtype
  case 1
    mstr = 'average_ocdp_PREM';
    
  case 2
    mstr = 'local_ocdp_PREM';
    
  case 3
    mstr = 'local_ocdp_PREMVpRho_Vs1';

  case 4
    mstr = 'local_ocdp_PREMVpRho_Vs2';

  case 5
    mstr = 'local_ocdp_Vp3Rho2pt5Vs0';

  case 6
    mstr = 'local_ocdp_Vp4Rho2Vs2'

  case 7
    mstr = 'local_ocdp_Vp4Rho3Vs0';

end

% Name it. (e.g., './P0045/mode_1_2.50Hz.txt')
staticdir = fullfile(getenv('HUNGA'), 'code', 'static', 'modes', mstr);
fname = fullfile(staticdir, kstnm, sprintf('mode_1_%.2fHz.txt', freq));

% Read it.
fid = fopen(fname, 'r');
C = textscan(fid, '%f %f', 'MultipleDelimsAsOne', true, 'Delimiter', ' ');
fclose(fid);

% Parse it.
amp = C{1}; % Phi_m
depth = C{2};

% Return value at station depth (via interpolation).
stdp = hunga_readstdp(kstnm);
stamp = interp1(depth, amp, stdp);

% Return maximum amplitude and that depth.
[~, idx] = max(amp);
maxdepth = depth(idx);
maxamp = amp(idx);

% % The integration of squared eigenfunction across all depths should equal 1 in
% % the average-depth case (not true for truncated/local-depth (shallow) modes).
% if mtype == 1
%     norm_amp = sum(amp(2:end).^2 .* diff(depth));
%     norm_diff = abs(norm_amp-1);
%     if norm_diff < 1e-3
%         % 1 per mille seems sufficient
%         fprintf('Pass: Eigenfunction properly normalized (differs from 1 by %.4e)\n', norm_diff)

%     else
%         try
%         error('Fail: Eigenfunction not properly normalized')
%         catch
%             keyboard

%         end
%     end
% end

% Plot it.
if plt
    %figure
    ax = gca;
    hold(ax, 'on')
    plot(amp, depth, 'k');
    plot(stamp, stdp, 'ro', 'MarkerFaceColor', 'r');
    ax.YDir = 'reverse';
    xlabel('Normalized Mode Amplitude');
    ylabel('Depth (m)');
    hold(ax, 'on')
    box(ax, 'on')

end
