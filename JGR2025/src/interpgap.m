function [interp_x, interp_val, interp_idx, gap_idx] = interpgap(x, gap, perc, plt)
% [interp_x, interp_val, interp_idx, gap_idx] = INTERPGAP(x, gap, perc, plt)
%
% Fill gaps in merged SAC file via interpolation.
%
% Input:
% x             SAC time series
% gap           SAC gaps from `readgap`
% perc          Percentage of gap length before/after for interpolation (def: 25)
% plt           true to plot (def: false)
%
% Output:
% interp_x      SAC time series with gaps filled via interpolation
% interp_val    Value of interpolation
% interp_idx    Indices of x before/after gap used for interpolation
% gap_idx       Indices of x of each gap
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Feb-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('perc', 25)
defval('plt', false)

% Interpolation requires consideration of a non-zero percentage of the gap
% before/after.
if perc <= 0
    error('`perc` must be positive')

end

% Compute interpolations before filling
% (don't want filled gap affecting interpolation of next gap?)
for i = 1:length(gap)
    gap_len = length(gap{i}(1):gap{i}(2));
    interp_buffer = ceil(gap_len*perc/100);
    interp_idx{i} = [gap{i}(1)-interp_buffer:gap{i}(1)-1 ...
                     gap{i}(2)+1:gap{i}(2)+interp_buffer];

    % Short percentages result in empty interpolation indices because the
    % percentage of the gap inspected before/after is less than one sample.
    if isempty(interp_idx{i})
        interp_idx{i} = [gap{i}(1) gap{i}(2)];

    end

    % Long gaps relative to length of trace result can result in interpolation
    % indices running off edges.
    interp_idx{i}(find(interp_idx{i} < 1)) = [];
    interp_idx{i}(find(interp_idx{i} > length(x))) = [];

    gap_idx{i} = [gap{i}(1):gap{i}(2)];

    % 'spline' did not work; produced wild amplitudes
    % 'spline' as an option to `interp` is the same as `spline()`
    % 'pchip' is the same as 'cubic'
    interp_val{i} = interp1(interp_idx{i}, x(interp_idx{i}), gap_idx{i}, 'pchip');

    % plot(interp_idx{i}, x(interp_idx{i}), 'ko')
    % hold on
    % plot(gap_idx{i}, spl{i})
    % keyboard
    % close

end

% Replace all gaps with interpolation.
interp_x = x;
for i = 1:length(gap)
    interp_x(gap_idx{i}) = interp_val{i};

end

if plt
    figure
    ax = gca;
    plot(x, 'k-')
    %plot(interp_x, 'ro')
    axis tight
    col = hsv(length(gap));
    hold on
    for i = 1:length(gap)
        %plot(ax, [gap{i}(1) gap{i}(1)], ax.YLim, 'Color', col(i,:));
        %plot(ax, [gap{i}(2) gap{i}(2)], ax.YLim, 'Color', col(i,:));

        gap_idx_plus1 = [gap{i}(1)-1:gap{i}(2)+1];;
        plot(ax, gap_idx_plus1, interp_x(gap_idx_plus1), 'o-', 'Color', col(i,:));

        figure
        plot(gap_idx_plus1, interp_x(gap_idx_plus1), 'o-', 'Color', col(i,:));

    end
end
