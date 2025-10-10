function [fname, fsuf, fpath] = stripsuf(fname)
% [fname, fsuf, fpath] = STRIPSUF(fname)
%
% Strip suffix from file paths, useful for cell arrays.
%
% Input:
% fname   Filename
%
% Output:
% fname   Filename
% fsuf    File Suffix
% fpath   File paths
% Author: Joel D. Simon
%
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Oct-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

%% RECURSIVE

if iscell(fname)
    for i = 1:length(fname)
        [aa{i}, bb{i}, cc{i}] = stripsuf(fname{i});

    end
    % Careful - `stripsuf` and `fileparts` output list orders differ
    fname = aa(:);
    fsuf = bb(:);
    fpath = cc(:);
    return

end

[fpath, fname, fsuf] = fileparts(fname);
