function filename = strippath(filename, rm_suffix)
% filename = STRIPPATH(filename, rm_suffix)
%
% Strips filename from path if separators ('/' or '\') present.
%
% Input:
% filename       Filename(s), possibly with a full path (cells okay)
% rm_suffix      true to also remove filename suffix (def: false)
%
% Output:
% filename       Filename(s) with full path removed, output in char or cell
%
% Ex1: (leading path stripped)
%    filename = '/mermaid35/identified/sac/m35.20141122T131937.sac'
%    filename = STRIPPATH(filename)
%
% Ex2: (no leading path; returns input)
%    filename = STRIPPATH('m35.20141122T131937.sac')
%
% Ex3: (cell arrays allowed)
%    filename = {'~/abc/test1.txt'; '~/abc/test2.txt'}
%    filename = STRIPPATH(filename)
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 13-Oct-2025, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

defval('rm_suffix', false)

%% Recursive.

if isa(filename, 'cell')

    %% Recursive.

    for i = 1:length(filename)
        aa{i} = strippath(filename{i}, rm_suffix);

    end
    filename = aa(:);

    return

end

% Sanity
if ~isa(filename,'char')
    error('`filename` must a be character array')

end

% If a file separator (e.g., '/') is present, remove it. Else, do
% nothing because the path is already stripped.
if contains(filename,filesep)
    [~, name, ext] = fileparts(filename);
    if rm_suffix
        filename = name;

    else
        filename = [name ext];

    end
end
