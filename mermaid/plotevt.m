function [F, sac, EQ] = plotevt(sac, lohi, sacdir, evtdir)
% [F, sac, EQ] = PLOTEVT(sac, lohi, sacdir, evtdir)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Jan-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

sac = fullsac(sac, sacdir);
[x,h] = readsac(sac);

pt0 = 0;
EQ_exists = false;
if isreviewed(sac, evtdir)
    EQ = getrevevt(sac, evtdir);
    EQ = EQ(1);
    if ~isempty(EQ.TaupTimes)
        pt0 = EQ.TaupTimes(1).pt0;
        if pt0 ~= h.B
            error('h.B ~- EQ.TaupTimes(1).pt0')

        end
        EQ_exists = true;

    end
end

xax = xaxis(h.NPTS, h.DELTA, pt0);

x = detrend(x, 'contsant');
x = detrend(x, 'linear');
x = x.*tukeywin(length(x));
xf = bandpass(x, efes(h), lohi(1), lohi(2));
xf(1:10) = NaN; % cut remaining edge effects
xf(end-10:end) = NaN;

F.f = figure;
F.ax = gca;
hold(F.ax, 'on')

F.pl = plot(xax, xf);
shrink(F.ax, 1, 2)
axesfs(F.f, 15, 15)
symaxes(F.ax, 'y');
if EQ_exists
    for i = 1:length(EQ.TaupTimes)
        F.plph(i) = plot(repmat(EQ.TaupTimes(i).truearsecs, 1, 2), F.ax.YLim);
        F.txph{i} = EQ.TaupTimes(i).phaseName;

    end
    F.lgph = legend(F.plph, F.txph{:});

end
hold(F.ax, 'off')


F.tl = title(strippath(sac), 'FontWeight', 'Normal');
F.xl = xlabel(F.ax, 'time (s)');
F.yl = ylabel(F.ax, 'counts');

box(F.ax, 'on')
longticks(F.ax, 2)
[F.lghz, F.txhz] = textpatch(F.ax, 'SouthEast', sprintf('%.1f--%.1f Hz', lohi));

latimes
