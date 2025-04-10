function writeginput(sac)
% WRITEGINPUT(sac)
%
% Manually identify time windows of local events to be cut.
%
% Use spacebar (or cursor or any key); don't MOVE OR resize fig; don't click
% outside axis (e.g., in command window to return) before hitting return to
% complete
%
% Developed as: hunga_ginput.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 07-Nov-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

sac = hunga_fullsac(sac);
staticdir = fullfile(getenv('HUNGA'), 'code', 'static');

prepost = [30 60];
lohi = [5 10];
popas = [4 1];

if contains(sac, {'H11' 'H03'})
    [x, h] = readsac(sac);
    x = bandpass(x, efes(h), lohi(1), lohi(2), popas(1), popas(2));
    gap = [];

else
    [x, h, gap] = hunga_transfer_bandpass(sac, lohi, popas);

end
[xw, W, tt, EQ] = hunga_timewindow(x, h, prepost(1), prepost(2));
xax = (W.xax - tt.truearsecs) / 60;
f = figure;
fullscreen(f);
ax = axes;
hold(ax, 'on')
%fullscreen(f);
plot(ax, xax, xw, 'b');
axis tight
if ~isempty(gap)
    for i = 1:length(gap)
        win_gap = gap{i} - (W.xlsamp - 1);
        if win_gap(1) > 0 && win_gap(end) < length(xax)
            plot(ax, xax(win_gap), ax.YLim, 'r')

        end
    end
end
plot(ax, [0 0], ax.YLim, 'k--')
hold(ax, 'on')
ax.Box =  'on';
ax.XLim = [-prepost(1) prepost(2)];

fprintf('%s - select points. I''m waiting...\n', h.KSTNM)
[pt, ~] = ginput; % select until you hit return key
if mod(length(pt), 2)
    error('Selected number of points must be even (expecting pairs)')

end
samp = nearestidx(xax, pt) + (W.xlsamp - 1);

fname = fullfile(staticdir, sprintf('%s_ginput.txt', h.KSTNM));
writeaccess('unlock', fname, false)
fid = fopen(fname, 'w+');
for i = 1:length(samp)
    fprintf(fid, '%i\n', samp(i));

end
fclose(fid);
writeaccess('lock', fname)
close
