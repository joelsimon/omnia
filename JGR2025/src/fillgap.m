function fill_x = fillgap(x, gap, val, perc, fs)
% fill_x = FILLGAP(x, gap, val, perc, fs)
%
% Fill gaps with specified value.
%
% Input:
% x          Gappy time series
% gap        Cell array of gap indices, e.g., from readginput.m
% val        Fill value (def: 0)*
% perc       Buffer length to extend fill, as percentage of gap (def: 0)
% fs         Sampling frequency (Hz)
%
% Output:
% fill_x     Time series with gaps filled
%
% *use val=-12345 to fill gap with mean of data 1 min before/1 min after gap
% *if `val=-12345` then  `fs` must be supplied
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Feb-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

defval('val', NaN)
defval('perc', 0)

fill_x = x;
fill_val = val;
for i = 1:length(gap)
    gap_len = length(gap{i}(1):gap{i}(2));
    buf_len = ceil(gap_len*perc/100);

    fill_idx{i}(1) = gap{i}(1) - buf_len;
    fill_idx{i}(2) = gap{i}(2) + buf_len;

    if fill_idx{i}(1) < 1
        fill_idx{i}(1) = 1;

    end

    if fill_idx{i}(2) > length(x)
        fill_idx{i}(2) = length(x);

    end

    if val == -12345
        lgap = gap{i}(1);
        rgap = gap{i}(end);
        nsamp = 60 * fs;

        lsamp = [lgap-1-nsamp:lgap-1];
        rsamp = [rgap+1:rgap+1+nsamp];

        if lsamp(1) < 1
            lsamp = 1;

        end
        if rsamp(end) > length(x)
            rsamp(end) = length(x)

        end
        lseg = x(lsamp);
        rseg = x(rsamp);
        fill_val = mean([lseg ; rseg]);

    end
    fill_x(fill_idx{i}(1):fill_idx{i}(2)) = fill_val;

end
