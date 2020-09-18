function reqdetdiff(s_req, s_det, diro)
% REQDETDIFF(s_req, s_det, diro)
%
% NB: the max correlation is forced to 1 for plotting purposes; does not imply
% the data are exactly correlated.
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('diro', fullfile(getenv('MERMAID'), 'processed'))
defval('test_diro', fullfile(getenv('MERMAID'), 'test_processed'))
defval('s_req', fullsac('20200805T121328.22_5F62A85C.MER.REQ.WLT5.sac', diro))
defval('s_det', fullsac('20200805T121329.22_5F2AF4E8.MER.DET.WLT5.sac', test_diro))

%%______________________________________________________________________________________%%
% Detected: returned.
[x_det, h_det] = readsac(s_det);
xax_det = xaxis(h_det.NPTS, h_det.DELTA, 0);
seisdate_det = seistime(h_det);
det_date = seisdate_det.B;

%%______________________________________________________________________________________%%
% Request: returned
[x_req, h_req] = readsac(s_req);

% To test: input same DET and REQ SAC file, uncomment one of these x_reqs, this
%          xax_req, and comment the other xax_req; comment next plot block
% x_req = [zeros(30,1) ; x_req];
% x_req = x_req(31:end);
% xax_req = xaxis(length(x_req), h_req.DELTA, 0);
xax_req = xaxis(h_req.NPTS, h_req.DELTA, 0);
seisdate_req = seistime(h_req);
req_date = seisdate_req.B;

% Request: command
req_cmd_datestr = reqdate(seisdate_det.B);
req_cmd_date = datetime(strrep(req_cmd_datestr, 'T', ''), ...
                        'Format', 'uuuu-MM-ddHH_mm_ss', ...
                        'TimeZone', 'UTC');

%%______________________________________________________________________________________%%
% Plot them on a common UTC datetime axis to see the offset between them.
xax_date_det = linspace(seisdate_det.B, seisdate_det.E, h_det.NPTS);
xax_date_req = linspace(seisdate_req.B, seisdate_req.E, h_req.NPTS);

figure
hold on
plot(xax_date_det, x_det, 'k')
plot(xax_date_req, x_req, 'r')
lg = legend( 'DET', 'REQ');
box on
hold off
title('DET and REQ plotted in terms of absolute UTC time')

%%______________________________________________________________________________________%%
% Plot the two time series on top of one another, with a pt0 = 0 s reference (so
% we are ignoring their absolute UTC start time), and compute their cross
% correlation. If everything were perfect that time would be the time shift
% between their start times.
figure

% Seismograms.
[~, ha1] = krijetem(subnum(2,1));
pl_det = plot(ha1(1), xax_det, x_det, 'k');
hold(ha1(1), 'on')
pl_req = plot(ha1(1), xax_req, x_req, 'r');
xlim(ha1(1), [95 105])
xlabel(ha1(1), 'seconds into seismogram (arbitrary start time; DET != REQ)')
ylabel(ha1(1), 'Counts')
lg1 = legend(ha1(1), [pl_det pl_req], 'DET', 'REQ');

% Cross correlations: REQ is shifted w.r.t to DET.
[xcorr_raw, lags] = xcorr(x_det, x_req);
xcorr_norm = norm2max(xcorr_raw);

xax_xcorr = lags*h_det.DELTA;
[max_xcorr, max_xcorr_idx] = max(abs(xcorr_norm));
max_xcorr_time_shift = xax_xcorr(max_xcorr_idx);

plot(ha1(2), xax_xcorr, xcorr_norm, 'r');
hold(ha1(2), 'on')
plot(ha1(2), [max_xcorr_time_shift max_xcorr_time_shift], [0 1], 'r');
xlim(ha1(2), [max_xcorr_time_shift-1 max_xcorr_time_shift+1])
ylim(ha1(2), [0 1])
xlabel(ha1(2), 'Time shift of REQ w.r.t. DET (s)')
ylabel(ha1(2), 'X-corr (arbitrarily scale)') % max correlation forced to 1
lgtx = textpatch(ha1(2), 'NorthEast', sprintf('max shift = %0.2f s', max_xcorr_time_shift));
lgtx.Box = 'off';

%%______________________________________________________________________________________%%
% Ideally the time shift at the max correlation would equal the start time difference.

start_time_diff = seconds(req_date - det_date);
total_time_offset = start_time_diff - max_xcorr_time_shift;

% Finish with printouts.

%%______________________________________________________________________________________%%
fprintf('\nAccording to the SAC headers:\n')

tdiff_req_cmd = seconds(req_date - req_cmd_date);
if tdiff_req_cmd == 0
    fprintf('* the REQ start date matches the command exactly')

elseif tdiff_req_cmd < 0
    fprintf('* the REQ seismogram begins %.2f s earlier than commanded\n', tdiff_req_cmd);

else
    fprintf('* the REQ seismogram begins %.2f s later than commanded\n', tdiff_req_cmd);

end

if start_time_diff == 0
    fprintf('* REQ and DET seismogram start at exactly the same UTC time\n')

elseif start_time_diff < 0
    fprintf('* REQ starts %.2f s before the DET seismogram\n', -start_time_diff)

else
    fprintf('* REQ starts %.2f s after the DET seismogram\n', start_time_diff)

end

fprintf('\n---------------------------------------------------------------------\n')

fprintf('Comparing their arrays in arbitrary time:\n')
if isequal(x_det, x_req)
    fprintf('* REQ and DET data are exactly equal\n');

else
    fprintf('* REQ and DET data are not exactly equal\n')%: their max corr is %.3f%s\n', max_xcorr*100, '%');

end
if max_xcorr_time_shift == 0
    fprintf('* REQ and DET data are unshifted w.r.t to each other\n');

elseif max_xcorr_time_shift < 0
    fprintf('* REQ is delayed w.r.t. DET by %.2f s\n', -max_xcorr_time_shift);

else
    fprintf('* REQ precedes DET by %.2f s\n', max_xcorr_time_shift);

end

fprintf('\n---------------------------------------------------------------------\n')

fprintf('Therefore, assuming the DET start time is exactly correct:\n')
if total_time_offset== 0
    fprintf('* in absolute UTC time the REQ and DET seismograms have the same start time\n')

else
    fprintf('* in absolute UTC time the start time in the REQ header should be adjusted by %.2f s\n', total_time_offset)

end

% Format plots.
latimes
