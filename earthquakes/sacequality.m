function [iseq, cf, h1, h2] = sacequality(sac1, sac2, names, mess, excl)
% [iseq, cf, h1, h2] = SACEQUALITY(sac1, sac2, names, mess, excl)
%
% Compare two SAC files.
%
% Input:
% sac1,2      Full path SAC files to compare
% names       Cell array of field names to compare (def: sacfieldnames)
% mess        true for "Comparing..." message printout (def: true)
% excl        Cell array of field names to not compare (def: [])
%
% Output:
% iseq        true: SAC files are equal
%             false: SAC files are not equal
% cf          More verbose output (comma-separated line of differences):
%             data: empty, or "not_equal"
%             alphanumeric header fields: empty, or "[char1]|[char2]"
%             float32 header fields: empty, or order-of-magnitude difference
% h1,2        SAC headers corresponding to sac1,2
%
% Ex1:
%    sac1 = '20180819T042909.08_5B7A4C26.MER.DET.WLT5.sac';
%    sac2 = '20180810T055938.09_5B6F01F6.MER.DET.WLT5.sac';
%    [iseq_same, cf_same] = SACEQUALITY(sac1, sac1)
%    [iseq_diff, cf_diff] = SACEQUALITY(sac1, sac2)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 28-Aug-2023, Version 9.3.0.713579 (R2017b) on GLNXA64

% Defaults.
defval('names', sacfieldnames)
defval('mess', true)

% Sanity.
if ~iscell(names)
    error('Input list of SAC header file names must be cell array')

end

% Read data and header.
if mess
    fprintf('Comparing:\n%s\n%s\n\n', sac1, sac2)

end
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

% Loop over requested SAC header variables.
for i = 1:length(names)
    name = names{i};
    if ~isempty(excl) && contains(name, excl)
        continue

    end
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
