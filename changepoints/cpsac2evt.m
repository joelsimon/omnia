function varargout = cpsac2evt(sac, redo, domain, n, inputs, model, ...
                               ph, diro, baseurl, varargin)
% [EQ, CP, rawevt, rawpdfc, rawpdfw] = ...
%    CPSAC2EVT(sac, redo, domain, n, inputs, model, ph, diro, baseurl, [param, value])
%
% CPSAC2EVT.m combines changepoint.m and sac2evt.m, and plots
% sac2evt.m theoretical arrival times on the wavelet-decomposed input
% seismogram.  Saves EQ and CP structures in [diro]/raw/[sac].evt and
% pdfs in [diro]/raw/[sac].pdf.
%
% Input:
% sac           SAC filename 
% redo          logical true to rerun and overwrite any previous *.raw.evt/pdf files
%               logical false to skip redundant sac2evt.m execution
%               (def: false)
% domain        'time' or 'time-scale', for changepoint.m
% n             Number of scales of wavelet decomposition
% inputs        Structure of other, less commonly adjusted inputs, 
%                   e.g., wavelet type (def:  cpinputs, see there)
% model         TauP model (def: 'ak135')
% ph            TauP phases (def: defphases)
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
% mkdir ~/cpsac2evt_example/raw/pdf ~/cpsac2evt_example/raw/evt
%
% Ex: (find the p phases for events deeper than 500 km)
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example';
%    [EQ, CP] = CPSAC2EVT(sac, true, 'time', 5, cpinputs, 'ak135', ...
%                         'P,p', diro, 1, 'includeallmagnitudes', true, ...
%                         'includeallorigins', true, 'mindepth', 500);
%
% See also: sac2evt.m, reviewevt.m, getevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 08-Dec-2018, Version 2017b

defval('sac', '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac')
defval('redo', false)
defval('domain', 'time')
defval('n', 5)
defval('inputs', cpinputs)
defval('model', 'ak135')
defval('ph', defphases)
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

    outargs = {EQ, CP, rawevt, rawpdfc, rawpdfw};
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
seisdate = seistime(h);
CP(1) = changepoint(domain, x, n, h.DELTA, h.B, 1, inputs);

% Window the seismogram such that it is 100 seconds long centered on
% the first arrival associated with the largest earthquake (or,
% roughly the center of the seismogram if the EQ structure is empty).
if ~isempty(EQ)
    first_arrival = EQ(1).TaupTimes(1).arsecs;
    [xw, W] = timewindow(x, 100, first_arrival, 'middle', h.DELTA, h.B);

else
    rough_middle_samp = round(length(CP.outputs.xax)/2);
    rough_middle_secs = CP.outputs.xax(rough_middle_samp);
    [xw, W] = timewindow(x, 100, rough_middle_secs, 'middle', h.DELTA, h.B);

end

% Windowed changepoint (arrival time) structure with the starting
% point being the time (in seconds) assigned in x to first sample of
% xw.
CP(2) = changepoint(domain, xw, n, h.DELTA, W.xlsecs, 1, inputs);

% Plot the arrivals theoretical arrivals on top of the seismogram and
% the wavelet-AIC arrivals at every scale.
for i = 1:2
    
    % Some plotting defaults.
    linewidth = 1;
    fonts = 11;

    % Plot arrival times for all scales -- in case of time-scale domain,
    % smooth by setting abe/dbe to central point of the time smear.
    F(i).fig = figure;
    F(i).f = plotchangepoint(CP(i), 'all', 'ar');

     % Add the scale-specific SNR and fatten arrival marks.
     for j = 1:length(CP(i).SNRj)
         if CP(i).SNRj(j) > CP(i).inputs.snrcut
             [F(i).bh(j), F(i).th(j)] = boxtexb('ul', F(i).f.ha(j + 1), ...
                                                sprintf('%8.1f', ...
                                                        CP(i).SNRj(j)), fonts);
             set(F(i).f.pl.vl{j}, 'LineWidth', 2*linewidth)

         end
     end
     
    if ~isempty(EQ)

        % Title the seismogram (first subplot).
        ax = F(i).f.ha(1);
        hold(ax, 'on')
        F(i).tl = title(ax, EQ(1).FlinnEngdahlRegionName, 'FontSize', ...
                        17, 'FontWeight', 'normal');
        F(i).tl.Position(2) = 1.7;

        % Mark all arrivals on the seismogram (first subplot).
        for j = 1:length(EQ)
            for k = 1:length(EQ(j).TaupTimes)
                tp = EQ(j).TaupTimes(k);
                tparr = tp.arsecs;

                if tparr >= CP(i).outputs.xax(1) && ...
                            tparr <= CP(i).outputs.xax(end)
                    F(i).tp{j}{k} = plot(ax, repmat(tparr, [1, 2]), ...
                                         ax.YLim, 'k--', 'LineWidth', linewidth);
                    phstr = sprintf('%s$_{%i}$', tp.phaseName, j);
                    F(i).tx{j}{k} = text(ax, tparr, 1.5, phstr, ...
                                         'HorizontalAlignment', 'Center');
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
            F(i).tp{1}{1}.LineWidth = 2*linewidth;
            F(i).tx{1}{1}.Position(2) = 0.9;
            F(i).tx{1}{1}.FontSize = 25;
            F(i).tx{1}{1}.FontWeight = 'bold';            

        end

        % Annotate the seismogram with the largest event info.
        magstr = sprintf('Mag.~=~%2.1f~%s', EQ(1).PreferredMagnitudeValue, ...
                         EQ(1).PreferredMagnitudeType);
        depthstr = sprintf('Depth~=~%6.2f~km', EQ(1).PreferredDepth);
        diststr = sprintf('$\\Delta$~=~%6.2f$^{\\circ}$', EQ(1).TaupTimes(1).distance);
        [F(i).bhul, F(i).thul] = boxtexb('ul', ax, strrep(magstr, ...
                                                          '_', '\_'), fonts);
        [F(i).bhll, F(i).thll] = boxtexb('ll', ax, strrep(strippath(sac), ...
                                                          '_', '\_'), fonts);
        [F(i).bhur, F(i).thur] = boxtexb('ur', ax, diststr, fonts);        
        [F(i).bhlr, F(i).thlr] = boxtexb('lr', ax, depthstr, fonts);        
        F(i).f.pl.x.LineWidth = linewidth;
        set([F(i).f.pl.aicj{:}], 'LineWidth', linewidth)
        set([F(i).f.pl.da{:}], 'LineWidth', linewidth)

    end

    % Shrink the distance between each subplot -- 'multiplier' is adjusted
    % depending on the number of subplots (the number of wavelet
    % scales plotted).
    multiplier = 0;
    switch CP(i).inputs.n
      case 3
        shrink(F(i).f.ha, 1, 1.53)
        for l = 1:length(F(i).f.ha)
            multiplier = multiplier + 1;
            movev(F(i).f.ha(l), multiplier * 0.08)
            
        end
        movev(F(i).f.ha, -0.1)
    
      case 5
        for l = 1:length(F(i).f.ha)
            multiplier = multiplier + 1;
            movev(F(i).f.ha(l), multiplier * 0.02)
            
        end
        movev(F(i).f.ha, -0.1)
            
      otherwise
        % Add to this list with trial and error given more examples with
        % differing sampling frequencies.
        warning('No figure formatting scheme available for %i %s', ...
                CP(i).n, plurals('scale', CP(i).n))
        
    end
    
    % Remove x-tick labels from all but last plot and label the lower x-axis.
    set(F(i).f.ha(1:end-1), 'XTickLabel', '')
    F(i).f.ha(1).YTick = [-1:1];
    F(i).f.ha(end).XLabel.String = sprintf(['time relative to %s UTC ' ...
                        '(s)'], datestr(seisdate.B));
    longticks(F(i).f.ha, 2)

end

latimes    

corw = {'complete', 'windowed'};
for i = 1:2
    pdfname = sprintf([strrep(strippath(sac), 'sac', '') '%s'], ...
                      [corw{i} '.raw']);
    rawpdf{i} = savepdf(pdfname, F(i).fig, fullfile(diro, 'raw', 'pdf'));
    fprintf('Saved %s\n\n', rawpdf{i}{:});
    
end

save(rawevt, 'EQ', 'CP', '-mat')
fprintf('Saved %s\n\n', rawevt);
outargs = {EQ, CP, rawevt, rawpdfc, rawpdfw};
varargout = outargs(1:nargout);
