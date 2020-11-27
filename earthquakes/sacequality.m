function cf = sacequality(sac1, sac2)
% cf = SACEQUALITY(sac1, sac2)
%
% Compare two SAC files bit-by-bit.
%
% Input:
% sac1,2      Full path SAC files to compare
%
% Output:
% cf          Comma-separate line of differences --
%             data: empty, or "not_equal)
%             alphanumeric header fields: empty, or "char1|char2"
%             float32 header fields: empty, or order-of-magnitude difference
%
% Ex1:
%    sac1 = '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac';
%    sac2 = '20180810T055938.09_5B6F01F6.MER.DET.WLT5.sac';
%    cf_same = SACEQUALITY(sac1, sac1)
%    cf_diff = SACEQUALITY(sac1, sac2)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Nov-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

cf = [];
fprintf('Comparing:\n%s\n%s\n\n', sac1, sac2)

% Read data and header.
[x1, h1] = readsac(sac1);
[x2, h2] = readsac(sac2);

% Define anonymous function to capture order-of-magnitude differences.
get_exp = @(xx) floor(log10(xx));

% First check the equality of the float32 binary data.
if ~isequal(x1, x2)
    l = sprintf('data: not_equal, ');
    cf = [cf  l];

end

% Then loop over every SAC-header field.
names = fieldnames(h1);
for i = 1:length(names)
    field = names{i};
    if ~isequal(h1.(field), h2.(field))
        if ~ischar(h1.(field))
            d = h1.(field) - h2.(field);
            l = sprintf('%s: %i, ', field, get_exp(d));

        else
            l = sprintf('%s: %s|%s, ', field, h1.(field), h2.(field));

        end
        cf = [cf  l];

    end
end

% Chop off final comma and space.
if ~isempty(cf)
    cf = cf(1:end-2);

end
