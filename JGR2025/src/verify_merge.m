function verify_merge(ser, lohi)
% VERIFY_MERGE(ser, lohi)
%
% Input:
% ser       Serial number, e.g., "23" or "0048" (not "P0023" or "P0048")
% lohi      Low- and high-corner frequencies for bandpass
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 30-Jan-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
close all

defval('ser', '49')
defval('lohi', [5 10])

popas = [4 1];
interp_perc = 50;
fill_perc = 0;

mt_freq_lo = [1/10 1/5 5 9.9];
mt_freq_hi = 2 * mt_freq_lo;
sacdir = fullfile(getenv('HUNGA'), 'sac');
um_sacdir = fullfile(sacdir, 'unmerged');
sac = globglob(um_sacdir, sprintf('*.%s_*.sac', ser));
sac = [sac ; globglob(sacdir, sprintf('*.%s_*.merged*.sac', ser))];
gap = readgap(sac{end});

figure;
ax = axes;
box(ax, 'on')
hold(ax, 'on')

for i = 1:length(sac)
    % Get sampling frequency first, regardless of if using
    % `readsac` or `mermaidtransfer`
    [~, h(i)] = readsac(sac{i});
    fs = efes(h(i), true);

    %% Toggle (comment on/off) between `readsac` and `mermaidtransfer`, here
    x{i} = readsac(sac{i});
    % if fs > 20
    %     x{i} = mermaidtransfer(sac{i}, mt_freq_hi);

    % else
    %     x{i} = mermaidtransfer(sac{i}, mt_freq_lo);

    % end

    %%  If using `readsac`, must interpolate "gap zero" gaps before filtering
    % (the final .sac in the list is merged.sac, hence that one gets the `interpgap`)
    if i == length(sac)
        x{i} = interpgap(x{i}, gap, interp_perc);

    end

    if ~isnan(lohi)
        x{i} = detrend(x{i}, 'constant');
        x{i} = detrend(x{i}, 'linear');
        x{i} = bandpass(x{i}, fs, lohi(1), lohi(2), popas(1), popas(2));

        %% In either case, should fill gaps with NaN to plot
        if i == length(sac)
            x{i} = fillgap(x{i}, gap, NaN, fill_perc);

        end
    end
    seisdate(i) = seistime(h(i));
    dax{i} = datexaxis(h(i).NPTS, h(i).DELTA, seisdate(i).B);
    pl(i) = plot(ax, dax{i}, x{i}, 'LineWidth', 2);
    lg_str{i} = sprintf('%02i: %i Hz', i, fs);

end
lg = legend(pl, lg_str{:});
axis tight

% Do second loop outside main due to warnings mucking up formatting.
clc
for i = 1:length(sac)
    fprintf('%02i: %s\n', i, strippath(sac{i}));

end

set(pl(end), 'Color', 'black', 'LineWidth', 0.5);
i = 1;
while true
    % if ~mod(i,2)
    %     uistack(pl(end), 'top')

    % else
    %     uistack(pl(end), 'bottom')

    % end
    uistack(pl(i), 'top')
    pause(1)
    i = i + 1;
    if i == length(pl)+1
        i = 1;

    end
end
