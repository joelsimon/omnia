function s = fullsac(singl, diro, returntype)
% s = FULLSAC(singl, diro, returntype)
%
% FULLSAC returns a cell array of full-path filenames of all SAC files
% in "diro" if "singl" is left empty (default) (Ex1)
%
% -OR-
%
% FULLSAC returns a single full-path filename if "singl" is a SAC
% partial-path filename, e.g., you want the full path on your system
% to '20180811T094852.09_5B6F01F6.MER.DET.WLT5.sac' (Ex2)
%
% Input:
% singl        Single SAC file, possibly with incomplete path,
%                  to which you wish to have the complete path returned.
%                  Leave empty to return all SAC files in diro (def: [])
% diro         Directory which contains (or whose subdirectories contain)
%                  the SAC files of interest (def: $MERMAID/processed/)
% returntype   For third-generation+ MERMAID only:
%              'ALL': both triggered and user-requested SAC files (def)
%              'DET': triggered SAC files as determined by onboard algorithm
%              'REQ': user-requested SAC files
%
% Output:
% s            Full-path SAC file(s) names, either:
%                 A cell array if "singl" is empty (Ex. 1)
%                 A char array if "singl" is input (Ex. 2)
%
% Ex1: (return all SAC files in all subdirs of /processed/)
%    s = FULLSAC([], fullfile(getenv('MERMAID'), 'processed'))
%
% Ex2: (return the complete path to a single SAC file)
%    s = FULLSAC('20180811T094852.09_5B6F01F6.MER.DET.WLT5.sac')
%
% See also: mermaid_sacf.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 25-Sep-2019, Version 2017b on GLNXA64

% Default is to return all SAC filenames in $MERMAID/processed.
defval('singl', [])
defval('diro', fullfile(getenv('MERMAID'), 'processed'))
defval('returntype', 'ALL')

% Sanity.
assert(isempty(singl) || issac(singl), ['Input ''singl'' must be ' ...
                    'either a SAC filename or [].']);
if verLessThan('MATLAB','2017b')
    foldercheck = @isdir;
else
    foldercheck = @isfolder;
end
assert(foldercheck(diro), 'Input ''diro'' must be a directory (folder).')

% Main.
if isempty(singl)
    % Nab all SAC files (**/* means search all subfolders).
    d = dir(fullfile(diro, '**/*sac'));
    if ~isempty(d)
        s = fullfile({d.folder}, {d.name});

    else
        s = [];
        warning('No .sac files found in %s', diro)

    end
    s = s(:);

else
    % Nab a single SAC file.
    d = dir(fullfile(diro, sprintf('**/%s', strippath(strtrim(singl)))));
    if ~isempty(d)
        s = fullfile(d.folder, d.name);

    else
        s = [];
        warning('%s was not found in %s or any of its subfolders.', ...
                singl, diro)
        return

    end
end

% Separate 'DET' (triggered) and 'REQ' (requested) data for MERMAID.
switch upper(returntype)
  case 'DET'
    idx = cellstrfind(s, 'MER.DET.*.sac');
    if isempty(idx)
        warning('No triggered (''DET'') SAC files found')
        s = [];
        return

    end

  case 'REQ'
    idx = cellstrfind(s, 'MER.REQ.*.sac');
    if isempty(idx)
        warning('No requested (''REQ'') SAC files found')
        s = [];
        return

    end

  case 'ALL'
    idx = [1:length(s)];

  otherwise
    error('Specify one of ''ALL'', ''DET'', or ''REQ'' for input: returntype')

end
s = s(idx);
