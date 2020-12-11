function varargout = cpsac2evt(sac, redo, domain, n, inputs, model, ph, conf, ...
                               fml, diro, baseurl, varargin)
% [EQ, CP, rawevt, rawpdfc, rawpdfw, F] = ...
%  CPSAC2EVT(sac, redo, domain, n, inputs, model, ph, conf, fml, diro, ...
%            baseurl, [param, value])
%
% CPSAC2EVT.m combines changepoint.m and sac2evt.m, and plots
% sac2evt.m theoretical arrival times on the wavelet-decomposed input
% seismogram.  Saves EQ and CP structures in [diro]/raw/[sac].evt and
% pdfs in [diro]/raw/[sac].pdf.
%
% Input:
% sac           SAC filename (def: '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
% redo          logical true to rerun and overwrite any previous *.raw.evt/pdf files
%               logical false to skip redundant sac2evt.m execution (def: false)
% domain        'time' or 'time-scale', for changepoint.m (def: 'time')
% n             Number of scales of wavelet decomposition (def: 5)
% inputs        Structure of other, less commonly adjusted inputs,
%                   e.g., wavelet type (def:  cpinputs, see there)
% model         TauP model (def: 'ak135')
% ph            TauP phases (def: defphases)
% conf         -1: skip confidence interval estimation with cpci.m (def)
%               0  compute confidence interval with cpci.m
%               1: compute confidence interval with cpci.m, M1 only
% fml           Smoothing, for 'time-scale' domain only:
%               'first': smooths all times to start of dabe smear
%               'middle: smooths all times to middle of dabe smear
%               'last': smooths all times to end of dabe smear
%               []: return complete time smear (def)
% diro          Parent directory of 'raw' subdirectory, where .evt
%                   and .pdf files saved (def: $MERMAID/events)
% baseurl       Default URL of data center, see sac2evt.m (def: 1)
% [param, value]  Comma separated parameter, value pair list for irisFetch.Events
%                   (def: see sac2evt.m)
%
% Output:
% EQ            EQ structure, from sac2evt.m (see there).
% CP            Changepoint structure, from changepoint.m (see there)
% rawevt        Output raw .evt filename
% rawpdfc/w     Output .pdf filenames for *complete* and *windowed*
% F             Structure containing both figure handles and other bits
%                  (def: [], if event already matched)
%
% CPSAC2EVT requires the following folders exist with write permission:
%    (1) [diro]/raw/evt/
%    (2) [diro]/raw/pdf/
%
% Wherein, for every SAC file, three associated event files are written:
%    (1) [diro]/raw/evt/*.raw.evt
%    (2) [diro]/raw/pdf/*.complete.raw.pdf
%    (3) [diro]/raw/pdf/*.windowed.raw.pdf
%
% For the following example first make the required directories:
%
%    mkdir ~/cpsac2evt_example/raw/pdf
%    mkdir ~/cpsac2evt_example/raw/evt
%
% And for both examples, use these inputs:
%
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example';
%
% Ex1: (match likely MERMAID phases, for all events globally)
%    [EQ, CP] = CPSAC2EVT(sac, true, 'time', 5, [], [], [], [], [], diro);
%
% Ex2: (find p and P phases for events deeper than 500 km)
%    [EQ, CP] = CPSAC2EVT(sac, true, 'time', 5, cpinputs, 'ak135', ...
%                         'P,p', -1, [], diro, 1, ...
%                         'includeallmagnitudes', true, ...
%                         'includeallorigins', true, 'mindepth', 500);
%
% See also: sac2evt.m, reviewevt.m, getevt.m
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 25-Sep-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('sac', '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
defval('redo', false)
defval('domain', 'time')
defval('n', 5)
defval('inputs', cpinputs)
defval('model', 'ak135')
defval('ph', defphases)
defval('conf', -1)
defval('fml', [])
defval('diro', fullfile(getenv('MERMAID'), 'events'))
defval('baseurl', 1)

% Separate filename from extension and determine if output files
% already exist.
[~, sans_sac] = fileparts(strtrim(sac));
rawdiro = fullfile(diro, 'raw');
rawevt  = fullfile(rawdiro, 'evt', [sans_sac '.raw.evt']);
rawpdfc = fullfile(rawdiro, 'pdf', [sans_sac '.complete.raw.pdf']);
rawpdfw = fullfile(rawdiro, 'pdf', [sans_sac '.windowed.raw.pdf']);

% Check if this SAC file has already been processed by cpsac2evt.m,
% and return outputs if so.
if ~redo && all([exist(rawevt, 'file') exist(rawpdfc, 'file') ...
                 exist(rawpdfw, 'file')] == 2)

    % Load the raw output .mat file and return the EQ and CP structures.
    tmp = load(rawevt, '-mat');
    EQ = tmp.EQ;
    CP = tmp.CP;
    clear tmp;
    F = [];

    outargs = {EQ, CP, rawevt, rawpdfc, rawpdfw, F};
    varargout = outargs(1:nargout);
    fprintf(['\n%s.sac already processed by cpsac2evt:\n%s\nSet ''redo''= ' ...
             'true to run cpsac2evt again.\n\n'],  sans_sac, rawevt)

    return

end

% Match SAC file to cataloged events.
EQ = sac2evt(sac, model, ph, baseurl, varargin{:});

% Generate a changepoint (arrival time) structure considering the
% entire seismogram.
[x, h] = readsac(sac);
CP(1) = changepoint(domain, x, n, h.DELTA, h.B, 1, inputs, conf, fml);

% Window the seismogram such that it is 100 seconds long centered on
% the first arrival associated with the largest earthquake (or,
% roughly the center of the seismogram if the EQ structure is empty).
if ~isempty(EQ)
    first_arrival = EQ(1).TaupTimes(1).truearsecs;
    [xw, W] = timewindow(x, 100, first_arrival, 'middle', h.DELTA, h.B);

else
    rough_middle_samp = round(length(CP.outputs.xax)/2);
    rough_middle_secs = CP.outputs.xax(rough_middle_samp);
    [xw, W] = timewindow(x, 100, rough_middle_secs, 'middle', h.DELTA, h.B);

end

% Windowed changepoint (arrival time) structure with the starting
% point being the time (in seconds) assigned in x to first sample of
% xw.
CP(2) = changepoint(domain, xw, n, h.DELTA, W.xlsecs, 1, inputs, conf, fml);

% Plot the arrivals theoretical arrivals on top of the seismogram and
% the wavelet-AIC arrivals at every scale.
corw = {'complete', 'windowed'};
for i = 1:length(CP)
    % Plot annotated traces.
    F(i) = ploteqcp(EQ, CP(i), sac);

    % Save em.
    pdfname = sprintf([strrep(strippath(sac), 'sac', '') '%s'], ...
                      [corw{i} '.raw']);
    rawpdf{i} = savepdf(pdfname, F(i).fig, fullfile(diro, 'raw', 'pdf'));

end

% Save the .evt file with the EQ structure(s).
save(rawevt, 'EQ', 'CP', '-mat')
fprintf('Wrote: %s\n', rawevt);
outargs = {EQ, CP, rawevt, rawpdfc, rawpdfw, F};
varargout = outargs(1:nargout);
