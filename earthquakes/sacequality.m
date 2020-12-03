function [iseq, cf] = sacequality(sac1, sac2, names)
% [iseq, cf] = SACEQUALITY(sac1, sac2, names)
%
% Compare two SAC files.
%
% Input:
% sac1,2      Full path SAC files to compare
% names       Cell array of field names to compare (def: all)
%
% Output:
% iseq        true: SAC files are equal
%             false: SAC files are not equal
% cf          More verbose output (comma-separated line of differences):
%             data: empty, or "not_equal"
%             alphanumeric header fields: empty, or "[char1]|[char2]"
%             float32 header fields: empty, or order-of-magnitude difference
%
% Ex1:
%    sac1 = '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac';
%    sac2 = '20180810T055938.09_5B6F01F6.MER.DET.WLT5.sac';
%    [iseq_same, cf_same] = SACEQUALITY(sac1, sac1)
%    [iseq_diff, cf_diff] = SACEQUALITY(sac1, sac2)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 02-Dec-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('names', {})

% Sanity.
if ~iscell(names)
    error('Input list of SAC header file names must be cell array')

end

% Read data and header.
fprintf('Comparing:\n%s\n%s\n\n', sac1, sac2)
[x1, h1] = readsac(sac1);
[x2, h2] = readsac(sac2);

% Define anonymous function to capture order-of-magnitude differences.
get_exp = @(xx) floor(log10(xx));

% First check the equality of the float32 binary data.
cf = [];
if ~isequal(x1, x2)
    l = sprintf('data: not_equal, ');
    cf = [cf  l];

end

% Loop over the requested variables.
if isempty(names)
    names = fieldnames(h1);

end

% Loop over requested SAC header variables.
for i = 1:length(names)
    name = names{i};
    if ~isequal(h1.(name), h2.(name))
        if ~ischar(h1.(name))
            d = h1.(name) - h2.(name);
            l = sprintf('%s: %+i, ', name, get_exp(d));

        else
            l = sprintf('%s: %s|%s, ', name, h1.(name), h2.(name));

        end
        cf = [cf  l];

    end
end

% Check final equality and format output verbose output.
if isempty(cf)
    iseq = true;

else
    iseq = false;
    % Chop off final comma and space.
    cf = cf(1:end-2);

end
