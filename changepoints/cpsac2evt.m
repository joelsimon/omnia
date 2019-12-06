function varargout = cpsac2evt(sac, redo, domain, n, inputs, model, ...
                               ph, conf, fml, diro, baseurl, varargin)
% [EQ, CP, rawevt, rawpdfc, rawpdfw, F] = ...
%    CPSAC2EVT(sac, redo, domain, n, inputs, model, ph, ...
%              conf, fml, diro, baseurl, [param, value])
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
% See also: sac2evt.m, reviewevt.m, getevt.m, updateevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 06-Dec-2019, Version 2017b on GLNXA64

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
F = [];

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
[~, ~, ~, refdate] = seistime(h);
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
for i = 1:2

    % Some plotting defaults.
    LineWidth = 1;

    % Plot arrival times for all scales -- in case of time-scale domain,
    % smooth by setting abe/dbe to central point of the time smear.
    F(i).fig = figure;
    F(i).f = plotchangepoint(CP(i), 'all', 'ar', false, true);

    % Shrink the distance between each subplot -- 'multiplier' is adjusted
    % depending on the number of subplots (the number of wavelet scales
    % plotted).
    multiplier = 0;
    switch CP(i).inputs.n
      case 3
        shrink(F(i).f.ha, 1, 1.53)
        for l = 1:length(F(i).f.ha)
            multiplier = multiplier + 1;
            movev(F.f.ha(l), multiplier * 0.08)

        end
        movev(F(i).f.ha, -0.1)

      case 5
        for l = 1:length(F(i).f.ha)
            multiplier = multiplier + 1;
            movev(F(i).f.ha(l), multiplier * 0.015)

        end
        movev(F(i).f.ha, -0.1)

      otherwise
        % Add to this list with trial and error given more examples with
        % differing sampling frequencies.
        warning('No figure formatting scheme available for %i %s', ...
                CP(i).n, plurals('scale', CP.n))

    end
    %keyboard
    % Remove x-tick labels from all but last plot and label the lower x-axis.
    set(F(i).f.ha(1:end-1), 'XTickLabel', '')

    if ~isempty(EQ)
        % Title the seismogram (first subplot).
        ax = F(i).f.ha(1);
        hold(ax, 'on')
        F(i).tl = title(ax, EQ(1).FlinnEngdahlRegionName, 'FontSize', ...
                        17, 'FontWeight', 'normal');
        F(i).tl.Position(2) = ax.YLim(2) + 0.4*range(ax.YLim);

        % Mark all arrivals on the seismogram (first subplot).
        for j = 1:length(EQ)
            for k = 1:length(EQ(j).TaupTimes)
                tp = EQ(j).TaupTimes(k);
                tparr = tp.truearsecs;

                if tparr >= CP(i).outputs.xax(1) && ...
                            tparr <= CP(i).outputs.xax(end)
                    F(i).tp{j}{k} = plot(ax, repmat(tparr, [1, 2]), ...
                                         ax.YLim, 'k--', 'LineWidth', LineWidth);
                    phstr = sprintf('%s$_{%i}$', tp.phaseName, j);
                    F(i).tx{j}{k} = text(ax, tparr, 0, phstr, ...
                                         'HorizontalAlignment', 'Center');
                    F(i).tx{j}{k}.Position(2) = ax.YLim(2) + 0.2*range(ax.YLim);

                else
                    F(i).tp{j}{k} = [];
                    F(i).tx{j}{k} = [];

                end
            end
        end
        hold(ax, 'off')

        % Highlight the first-arriving phase associated with the largest event.
        if ~isempty(F(i).tp{1}{1})
            F(i).tp{1}{1}.Color = 'r';
            F(i).tp{1}{1}.LineStyle = '-';
            F(i).tp{1}{1}.LineWidth = 2*LineWidth;
            F(i).tx{1}{1}.Position(2) = ax.YLim(2) + 0.3*range(ax.YLim);
            F(i).tx{1}{1}.FontSize = 25;
            F(i).tx{1}{1}.FontWeight = 'bold';

        end

        % Capitalize only the first character of the magnitude string.
        magtype = lower(EQ(1).PreferredMagnitudeType);
        magtype(1) = upper(magtype(1));

        % Set Mww to generic Mw notation.
        if strcmp(magtype, 'Mww')
            magtype = 'Mw';

        end
        magstr = sprintf('%.1f~%s', EQ(1).PreferredMagnitudeValue, magtype);

        depthstr = sprintf('%.2f~km', EQ(1).PreferredDepth);
        diststr = sprintf('%.2f$^{\\circ}$', EQ(1).TaupTimes(1).distance);

        [F(i).f.lgmag, F(i).f.lgmagtx] = textpatch(ax, 'NorthWest', magstr);
        [F(i).f.lgdist, F(i).lgdisttx] = textpatch(ax, 'SouthWest', [diststr ', ' depthstr]);
    end
    % This time is w.r.t. the reference time in the SAC header, NOT
    % seisdate.B. CP.xax has the time of the first sample (input:
    % pt0) assigned to h.B, meaning it is an offset from some
    % reference (in this case, the reference time in the SAC
    % header).  The time would be relative to seisdate.B if I had
    % input pt0 = 0, because seisdate.B is EXACTLY the time at the
    % first sample, i.e., we start counting from 0 at that time.
    F(i).f.ha(end).XLabel.String = sprintf('time relative to %s UTC (s)\n[%s]', ...
                                           datestr(refdate), ...
                                           strippath(strrep(sac, '_', '\_')));
    longticks(F(i).f.ha, 3);
end

% Set interpreter to LaTeX and fonts to Times.
latimes

% Save the complete and windowed pdf.
corw = {'complete', 'windowed'};
for i = 1:length(F)
    % The axes have been shifted -- need to adjust the second (AIC) adjust
    % and re-tack2corner the annotations.
    for l = 1:length(F(i).f.ha)
        F(i).f.ha2(l).Position = F(i).f.ha(l).Position;
        F(i).f.ha2(l).YAxis.TickLabelFormat = '%#.2g';

    end

    if ~isempty(EQ)
        tack2corner(F(i).f.ha(1), F(i).f.lgmag, 'NorthWest');
        tack2corner(F(i).f.ha(1), F(i).f.lgdist, 'SouthWest');

        for l = 1:length(F(i).f.lgSNR)
            tack2corner(F(i).f.ha(l+1), F(i).f.lgSNR(l), 'SouthWest');

        end
    end

    % Save em.
    pdfname = sprintf([strrep(strippath(sac), 'sac', '') '%s'], ...
                      [corw{i} '.raw']);
    rawpdf{i} = savepdf(pdfname, F(i).fig, fullfile(diro, 'raw', 'pdf'));
    fprintf('Saved:\n %s\n', rawpdf{i}{:});

end

% Save the .evt file with the EQ structure(s).
save(rawevt, 'EQ', 'CP', '-mat')
fprintf('Saved:\n %s\n', rawevt);
outargs = {EQ, CP, rawevt, rawpdfc, rawpdfw, F};
varargout = outargs(1:nargout);
