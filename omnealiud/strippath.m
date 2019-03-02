function filename = strippath(filename)
% filename = STRIPPATH(filename)
%
% Strips filename from path if separators ('/' or '\') present.
%
% Input:
% filename       Filename, possibly with a full path
%
% Output:
% filename       Filename with full path removed
% 
% Ex1: (leading path stripped)
%    filename = '/mermaid35/identified/sac/m35.20141122T131937.sac'
%    filename = STRIPPATH(filename)
%
% Ex2: (no leading path; returns input)
%    filename = STRIPPATH('m35.20141122T131937.sac')
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Nov-2017, Version 2017b

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
