function merspec(s, fl)
% MERSPEC(s)
%
% QDP MERMAID spectrogram with JDS' defaults.
%
% Input:
% s         SAC filename
% fl        1 x 2 array of frequency limits (def: [0 fs/2])
%
% Ex:
%    MERSPEC('20180629T170731.06_5B3F1904.MER.DET.WLT5.sac', [1 8])
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 17-Nov-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Later, if required, set to [0 fs/2].
defval('fl', [])

% Read SAC file and generate time axis.
[x, h] = readsac(s);
xax = xaxis(h.NPTS, h.DELTA, 0);

% Window length and number of FFT points.
fs = efes(h);
wlen = 6*fs;
wolap = 0.7;
nfft = wlen;

% Lower limit of Y-axis on spectrogram; set higher than 0 to clip persistent and
% loud lower frequency sound in ocean.
if isempty(fl)
    fl = [0 fs/2];

end
spec_lowerlim = fl(1);
spec_upperlim = fl(2);

[~, spec_freqs, ~, spec_energy] = spectrogram2(x, nfft, fs, wlen, ceil(wolap*wlen), 's');
spec_pt0 = wlen / fs / 2;
spec_xax = xax + spec_pt0;
colormap(jet)

% Winnow spectral energy matrix to only contain data at frequencies equal to and
% above the requested lower limit. This is so that we can control the color
% limit of the axes.  Note that im.CData does NOT change even with the axis
% adjusted, so if we want to control color based on some metric of what is
% actually plotted we need to only plot the relevant spectrum.
spec_loweridx = nearestidx(spec_freqs, spec_lowerlim);
if spec_freqs(spec_loweridx) > spec_lowerlim
    spec_loweridx = spec_loweridx - 1;

end
spec_upperidx = nearestidx(spec_freqs, spec_upperlim);
if spec_freqs(spec_upperidx) > spec_upperlim
    spec_upperidx = spec_upperidx + 1;

end
spec_cutfreqs = spec_freqs(spec_loweridx:spec_upperidx);
spec_cutenergy = spec_energy(spec_loweridx:spec_upperidx, :);

% Remove mean from spctrum and normalize by std.
fin_spec = spec_cutenergy(isfinite(spec_cutenergy));
ms = mean(fin_spec);
ss = std(fin_spec);
spec_cutenergy = spec_cutenergy - ms;
spec_cutenergy = spec_cutenergy ./ ss;
spec_cutenergy(~isfinite(spec_cutenergy)) = NaN;

% Set all beyond energy +/- std to +/- std
min_std = -2;
max_std = +2;
spec_cutenergy(spec_cutenergy < min_std) = min_std;
spec_cutenergy(spec_cutenergy > max_std) = max_std;

ax = axes;
im = imagesc(ax, spec_xax, spec_cutfreqs, spec_cutenergy, 'AlphaData', ~isnan(spec_cutenergy));
axis xy


ax.YLim = [spec_lowerlim spec_upperlim];
cb = colorbar;

set(cb, 'TickDirection', 'out');
set(cb.Label, 'FontName', 'Times', 'String', 'Standard Deviation From Mean [dB Pa^2/Hz]', 'Interpreter', 'tex');

title(ax, strippath(underhyphen(s)))
xlabel(ax, 'Time [s]');
ylabel(ax, 'Hz')

shrink(ax, 1, 2)
longticks(ax, 2)
latimes2
