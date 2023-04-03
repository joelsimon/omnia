function dabe = smoothscale(dabe, fml)
% dabe = SMOOTHSCALE(dabe, fml)
%
% SMOOTHSCALE takes the output of wtspy.m, time smear sample spans of
% time-scale domain detail and approximation coefficients (dbe, abe,
% respectively, or a concatenation of the two), and returns a single
% sample which is either the first, middle (rounded), or last sample
% of the each dabe coefficient time smear.
%
% SMOOTHSCALE is useful to generate a smoothed x-axis for plotting.
%
% Input:
% dabe      dbe or abe, or some combination of the two, from wtspy.m
% fml       'first', 'middle', or 'last'
%
% Output:
% dabe      A single sample from the requested portion of the time smear
%
% See also: wtspy.m, plotchangepoint.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 03-Apr-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

for i = 1:length(dabe)
    if ~isnan(dabe{i})
        switch lower(fml)
          case 'first'
            dabe{i} = dabe{i}(:, 1);

          case 'last'
            dabe{i} = dabe{i}(:, 2);

          case 'middle'
            dabe{i} = round(mean(dabe{i}, 2));

          otherwise
            error('Specify either ''first'', ''middle'', or ''last'' for input `fml`')

        end
    else
        dabe{i} = NaN;

    end
end
