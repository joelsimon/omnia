function reqdetdiff(s_req, s_det, diro)
% REQDETDIFF(s_req, s_det, diro)
%
% Compares requested and detected MERMAID files.
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 19-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

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
start_time_diff = seconds(req_date - det_date);

% Request: command
req_cmd_datestr = reqdate(seisdate_det.B);
req_cmd_date = datetime(strrep(req_cmd_datestr, 'T', ''), ...
                        'Format', 'uuuu-MM-ddHH_mm_ss', ...
                        'TimeZone', 'UTC');

%%______________________________________________________________________________________%%
%% PLOT UTC TIME
% Plot them on a common UTC datetime axis to see the offset between them.
xax_date_det = linspace(seisdate_det.B, seisdate_det.E, h_det.NPTS);
xax_date_req = linspace(seisdate_req.B, seisdate_req.E, h_req.NPTS);

figure
hold on
plot(xax_date_det, x_det, 'k')
plot(xax_date_req, x_req, 'r')
% minmax.m does not accept datetime arrays.
xl1 = min([xax_date_det(1) xax_date_det(end) xax_date_req(1) xax_date_req(end)]);
xl2 = max([xax_date_det(1) xax_date_det(end) xax_date_req(1) xax_date_req(end)]);
xlim([xl1 xl2])
lg = legend( 'DET', 'REQ');
box on
hold off
title('DET and REQ in UTC time')

%%______________________________________________________________________________________%%
%% PLOT IN ARBITARY TIME

figure

% Seismograms.
[~, ha1] = krijetem(subnum(3,1));
pl_det = plot(ha1(1), xax_det, x_det, 'k');
hold(ha1(1), 'on')
pl_req = plot(ha1(1), xax_req, x_req, 'r');
xlim(ha1(1), [1 max([xax_det(end) xax_req(end)])])
xlabel(ha1(1), 'Seconds into DET and REQ seismograms')
ylabel(ha1(1), 'Counts')
lg1 = legend(ha1(1), [pl_det pl_req], 'DET', 'REQ');


%% PLOT ALIGNED AND TRUNCATED

% Compute their cross correlation.
[xcorr_norm, max_xcorr, xat_det, xat_req, dx_det, dx_req, px_det, px_req] = ...
    alignxcorr(x_det, x_req);


%% PLOT
% Delays form alignxcorr.m are always positive.
if dx_det > 0
    % REQ is advanced w.r.t. DET.
    delay_time = (dx_det-1) * h_det.DELTA;
    delay_time = -delay_time;

elseif dx_req > 0
    % REQ is delayed w.r.t. DET.
    delay_time = (dx_req-1) * h_req.DELTA;

else
    delay_time = 0;

end

% Generate x-axis for aligned and truncated DET and REQ signals where they
% are w.r.t. to DET; i.e., the signals are aligned at DET = 0 s.
xax_req_delayed = xax_req + delay_time;

pl2_det = plot(ha1(2), xax_det, x_det, 'k');
hold(ha1(2), 'on')
pl2_req = plot(ha1(2), xax_req_delayed, x_req, 'r');
xlabel(ha1(2), 'Time shift of REQ  w.r.t DET required for alignment (s)')
ylabel(ha1(2), 'Counts')
xlim(ha1(2), minmax([xax_det' xax_req_delayed']))
lg2 = legend(ha1(2), [pl2_det pl2_req], 'DET', 'REQ');

%% Plot the aligned traces on top of one another.
xax_xat_det = xaxis(length(xat_det), h_det.DELTA, 0);
xax_xat_req = xaxis(length(xat_req), h_req.DELTA, 0);

pl3_det = plot(ha1(3), xax_xat_det, xat_det, 'k');
hold(ha1(3), 'on')
pl3_req = plot(ha1(3), xax_xat_req, xat_req, 'r');
xlim(ha1(3), minmax([0 xax_xat_det' xax_xat_req']))
lg1 = legend(ha1(3), [pl3_det pl3_req], 'DET', 'REQ');
xlabel(ha1(3), 'Aligned and truncated')
ylabel(ha1(3), 'Counts')

% Format plots.
latimes

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
    fprintf('* REQ is delayed w.r.t to DET %.2f s\n', delay_time);

end

fprintf('\n---------------------------------------------------------------------\n')

fprintf('After aligning DET and REQ, and truncating them to be equal length:\n')
fprintf('* their normalized max cross correlation is %.2f %s\n', 100*max_xcorr, '%')
fprintf('* %.2f %s of DET was cut to match the signal common to REQ\n', px_det, '%')
fprintf('* %.2f %s of REQ was cut to match the signal common to DET\n\n', px_req, '%')
