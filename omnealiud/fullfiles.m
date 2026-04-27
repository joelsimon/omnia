function [fullpaths, duplicates, absentees] = fullfiles(basenames, pathdir)
% [fullpaths, duplicates, absentees] = FULLFILES(basenames, pathdir)
%
% Recursively find full paths by basename.
%
% INPUT:
% basenames    String, cellstr, or char array of basenames to find
% pathdir      String or char array root directory to search recursively
%
% OUTPUT:
% fullpaths    String array of unique matched full paths
% duplicates   Table of basenames with >1 recursive matches
% absentees    String array of basenames from basenames not found under pathdir
%
% Notes
%   - If the same basename appears multiple times under pathdir, it is excluded
%     from fullpaths and reported in duplicates.
%   - Matching is by basename only, not by relative path.
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 27-Apr-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% ChatGPT-5.3 prompt (for regenerating this function):
%
% Write a MATLAB function:
%   function [fullpaths, duplicates, absentees] = find_fullpaths_by_basename(A, B)
%
% Behavior:
% - A = list of basenames (string array, cellstr, or char)
% - B = root directory path
% - Recursively search B for all files (use dir(fullfile(B, "**", "*")))
% - Match files by basename ONLY (ignore relative paths)
%
% Outputs:
% - fullpaths: string array of full paths where basename appears EXACTLY ONCE
% - duplicates: table with variables:
%       basename (string)
%       paths (cell array of string arrays)
%   for basenames that appear >1 time under B
% - absentees: string array of basenames in A not found anywhere under B
%
% Requirements:
% - Normalize A to a unique string column vector
% - Exclude directories from search results
% - Preserve input order of A ("stable" behavior)
% - Do NOT include duplicates in fullpaths
% - Use straightforward, readable MATLAB (no toolboxes, no OOP)
% - Handle empty directory case gracefully
%
% Goal:
% Efficiently map basenames → full paths with explicit handling of duplicates and absentees files.

basenames = string(basenames);
pathdir = string(pathdir);

if ~isfolder(pathdir)
    error("Search root does not exist or is not a folder: %s", pathdir);
end

% Normalize requested basenames.
basenames = basenames(:);
basenames = basenames(basenames ~= "");
basenames = unique(basenames, "stable");

% Recursively list all files.
files = dir(fullfile(pathdir, "**", "*"));
files = files(~[files.isdir]);

if isempty(files)
    fullpaths = strings(0, 1);
    duplicates = table(strings(0,1), cell(0,1), ...
                       'VariableNames', {'basename', 'paths'});
    absentees = basenames;
    return

end

% Extract basenames and full paths.
foundNames = string({files.name}).';
foundPaths = fullfile(string({files.folder}).', foundNames);

% Keep only files whose basename is requested.
isWanted = ismember(foundNames, basenames);
foundNames = foundNames(isWanted);
foundPaths = foundPaths(isWanted);

fullpaths = strings(0, 1);

dupNames = strings(0, 1);
dupPaths = {};

absentees = strings(0, 1);

for k = 1:numel(basenames)
    name = basenames(k);
    idx = foundNames == name;
    n = nnz(idx);
    if n == 0
        absentees(end+1, 1) = name;

    elseif n == 1
        fullpaths(end+1, 1) = foundPaths(idx);

    else
        dupNames(end+1, 1) = name;
        dupPaths{end+1, 1} = foundPaths(idx);

    end
end

duplicates = table(dupNames, dupPaths, ...
                   'VariableNames', {'basename', 'paths'});
