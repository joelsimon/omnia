function verify_timewindow2_travtimeadj
% VERIFY_TIMEWINDOW2_TRAVTIMEADJ
%
% The adjusted travel time is theoretically SHORTER because some segment
% traveled as faster P-wave; if time is removed from travel time then the actual
% arrival is EARLIER in absolute time compared to unadjusted value, and so the
% adjusted waveform appears to be shifted to the right compared to unadjusted
% because the adjusted arrival is EARLIER in absolute time.

clc
close all

env = true;

sac = fullfile(getenv('HUNGA'), 'sac', '20220115T040306.0041_63385B5E.MER.REQ.merged.sac');
[x, h] = hunga_transfer_bandpass(sac);

[xw_raw, W_raw, tt_raw] = hunga_timewindow2(x, h, -15, +45, '1.483kmps');
[xw_adj, W_adj, tt_adj] = hunga_timewindow2_travtimeadj(x, h, -15, +45, 'H03S1', 1483, -1385);

if env
    x = envelope(x, 30*efes(h), 'rms');
    xw_raw = envelope(xw_raw, 30*efes(h), 'rms');
    xw_adj = envelope(xw_adj, 30*efes(h), 'rms');

end

orange = [255 165 0]/256;

%% Proof 1: neither function changes waveform in absolute time frame, only
%% what sample the arrival supposedly comes at.
seisdate = seistime(h);
dax = datexaxis(length(x), h.DELTA, seisdate.B);
dax_raw = datexaxis(length(xw_raw), h.DELTA, seisdate.B+seconds(W_raw.xlsecs));
dax_adj = datexaxis(length(xw_adj), h.DELTA, seisdate.B+seconds(W_adj.xlsecs));
figure
ax = gca;
hold on
plot(dax, x, 'k');
plot(dax_raw, xw_raw, '--', 'Color', orange);
plot(dax_adj, xw_adj, 'g--');
axis tight
box on
plot([tt_raw.arrivaldatetime tt_raw.arrivaldatetime], ax.YLim, '-', 'Color', orange);
plot([tt_adj.arrivaldatetime tt_adj.arrivaldatetime], ax.YLim, 'g-');
legend('abs', 'raw', 'adj')
xlabel('UTC Datetime')
latimes2
savepdf([mfilename '1'])

%% Proof 2: when plotted w.r.t. theoretical arrival the adjusted waveform is
%% shifted to right (as expected; theoretical arrival is EARLIER in time).
xax_raw = W_raw.xax - tt_raw.truearsecs;
xax_adj = W_adj.xax - tt_adj.truearsecs;
figure
ax = gca;
hold on
plot(xax_raw, xw_raw, '-', 'Color', orange);
plot(xax_adj, xw_adj, 'g-');
axis tight
plot([0 0], ax.YLim, 'k');
box on
legend('raw', 'adj')
xlabel('Time Relative to Theoretical Arrival')
latimes2
savepdf([mfilename '2'])