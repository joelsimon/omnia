function sacfiles = mermaid_sacf(IDorUID,diro) 
% sacfiles = MERMAID_SACF(IDorUID,diro) 
%
% MERMAID_SACF returns a cell array of full file names to all GeoAzur
% MERMAID SAC file in identified/unidentified if first input is 'ID',
% 'UID', or 'all',
%
% -OR-
%
% MERMAID_SACF returns a single SAC file name if the first input is a
% single SAC file (with or without full path).  If duplicates exist
% (SAC file in both /identified/ and /unidentified/) it will return
% the path to the former.  See mermaid_sacf_duplicate.m
%
% Input:
% IDorUID         Case-insensitive string denoting request of identified  ('ID'), 
%                     unidentified ('UID'), or all ('all') event filenames;  
%                 -OR- a single SAC filename (with or without full path)
%
% diro            Directory which stores individual float dirs
%                     (def: $MERAZUR) 
%
% Output:
% sacfiles        Cell array (or single char array) containing full paths 
%                     to all files matching query
%
% Ex1: (return all SAC file for identified events)
%    sacfiles = MERMAID_SACF('id')
%
% Ex2: (return full path to a single SAC file)
%    sacfiles = MERMAID_SACF('m12.20150527T200008.sac')
%
% See also: mermaid_sacf_duplicates.m, fullsac.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 21-Aug-2018, Version 2017b

% Parent data directory
defval('IDorUID','id')
defval('diro', getenv('MERAZUR'))

% Remove errant whitespace.
IDorUID = strtrim(IDorUID);

% If a path-less sacfile is input (often want to inspect a single
% seismogram but don't know the full path), return the full path.
if strcmp(suf(IDorUID), 'sac')  
    d = dir(fullfile(diro, sprintf('**/%s'), strippath(IDorUID)));

    % Sometimes the same file in found in multiple places (i.e.,
    % ''m16.20150323T102337.sac', which is in both 'identified' and
    % 'unidentified').  In that case return the first instance.

    if ~isempty(d)
        sacfiles = fullfile(d(1).folder, d(1).name);

    else
        warning('%s was not found in %s or any of its subfolders.', ...
                IDorUID, diro)
        sacfiles = [];

    end
    
    return
    
end

% Want identified or unidentified?
if strcmpi(IDorUID,'ID') || strcmpi('IDorUID','identified')
    d = dir(fullfile(diro,'**/identified/**/*.sac'));

elseif strcmpi(IDorUID,'UID') || strcmpi(IDorUID,'unidentified')
    d = dir(fullfile(diro,'**/unidentified/**/*.sac'));
    
elseif strcmpi(IDorUID,'both') || strcmpi(IDorUID,'all')
    d = dir(fullfile(diro,'**/*.sac'));
    
else
    error('Unrecognized ''IDorUID'' option')
end

if ~isempty(d)
    sacfiles =  fullfile({d.folder}, {d.name});

else
   warning('No SAC files found in %s', diro)
   sacfiles = [];
end
