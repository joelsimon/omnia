function diffs = structdiff(a, b)
%STRUCTDIFF Return nested field paths that differ between structs.
%
% diffs = STRUCTDIFF(a, b)
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 24-Apr-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)


fa = fieldnames(a);
fb = fieldnames(b);
allFields = union(fa, fb);

diffs = strings(0, 1);
prefix = '';
for i = 1:numel(allFields)
    f = allFields{i};
    path = prefix + string(f);

    if ~isfield(a, f) || ~isfield(b, f)
        diffs(end+1, 1) = path;
        continue

    end

    va = a.(f);
    vb = b.(f);

    if isstruct(va) && isstruct(vb)
        nested = local_structdiff(va, vb, path + ".");
        diffs = [diffs; nested];

    elseif ~isequaln(va, vb)
        diffs(end+1, 1) = path;

    end
end
