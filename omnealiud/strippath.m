function filename = strippath(filename)
% filename = STRIPPATH(filename)
%
% Strips filename from path if separators ('/' or '\') present.
%
% Input:
% filename       Filename(s), possibly with a full path (cells okay)
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
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 17-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

%% Recursive.

if isa(filename, 'cell')

    %% Recursive.

    for i = 1:length(filename)
        temp_filename{i} = strippath(filename{i});

    end
    filename = temp_filename(:);

    return

end

% Sanity
if ~isa(filename,'char')
    error('''filename'' must a character array')

end

% If a file separator (e.g., '/') is present, remove it. Else, do
% nothing because the path is already stripped.
if contains(filename,filesep)
    [~,file,ext] = fileparts(filename);
    filename = [file ext];

end
