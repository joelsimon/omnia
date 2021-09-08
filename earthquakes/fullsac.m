function s = fullsac(singl, diro, returntype, ofuse)
% s = FULLSAC(singl, diro, returntype, ofuse)
%
% FULLSAC returns a cell array of full-path filenames of all SAC files
% in "diro" if "singl" is left empty (default) (Ex1)
%
% -OR-
%
% FULLSAC returns a single full-path filename if "singl" is a SAC partial-path
% filename, e.g., you want the full path on your system to
% '20180811T094852.09_5B6F01F6.MER.DET.WLT5.sac' (Ex2).  If there are multiples
% of the same filename in the path, supply an optional string that may be
% 'ofuse' in determining which to keep, e.g., like an event ID number which will
% be part of the fullpath (Ex3).
%
% Input:
% singl        Single SAC file, possibly with incomplete path,
%                  to which you wish to have the complete path returned.
%                  Leave empty to return all SAC files in diro (def: [])
%                  (really, it can be any filename...doesn't have to be SAC)
% diro         Directory which contains (or whose subdirectories contain)
%                  the SAC files of interest (def: $MERMAID/processed/)
% returntype   For third-generation+ MERMAID only:
%              'ALL': both triggered and user-requested SAC files (def)
%              'DET': triggered SAC files as determined by onboard algorithm
%              'REQ': user-requested SAC files
% ofuse        A string which you expect in the fullpath filename, e.g.,
%                  to differentiate among multiple matching SAC filenames
%                  if a single SAC file is requested, or to winnow a larger
%                  list of SAC files if an entire directory is requested
%                  (for example, an event ID number or MERMAID name) (def: [])
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
% Ex3: (multiple versions of this .evt file exist, including one in an example
%       directory in $MERMAID/events/ branch: simon2020; retrieve the original,
%       which is linked with its event ID)
%    singl = 'AM.R06CD.00.SHZ.2019.312.10.44.49.evt';
%    diro = fullfile(getenv('MERMAID'), 'events');
%    ofuse = '11143029';  % Event ID
%    s = FULLSAC(singl, diro, [], ofuse)
%
% Ex4: (retrieve all MERMAID SAC files that were inverted using 5 wavelet scales)
%    diro = fullfile(getenv('OMNIA'), 'exfiles');
%    ofuse = 'WLT5';
%    s = FULLSAC([], diro, [], ofuse)
%
% See also: mermaid_sacf.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 08-Sep-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default is to return all SAC filenames in $MERMAID/processed.
defval('singl', [])
defval('diro', fullfile(getenv('MERMAID'), 'processed'))
defval('returntype', 'ALL')
defval('ofuse', [])

% Main.
if isempty(singl)
    % Nab all SAC files (**/* means search all subfolders).
    d = dir(fullfile(diro, '**/*.sac'));
    if ~isempty(d)
        s = fullfile({d.folder}, {d.name});

    else
        s = [];
        warning('No .sac files found in %s', diro)

    end

    % Narrow down SAC file list with useful (sub)string, if supplied.
    if length(s) > 1 && ~isempty(ofuse)
        idx = find(contains(s, ofuse));
        s = s(idx);

        if isempty(s)
            warning('No .sac files containing (sub)string %s found in %s', ofuse, diro)

        end
    end
    s = s(:);

else
    % Nab a single SAC file.
    d = dir(fullfile(diro, sprintf('**/%s', strippath(strtrim(singl)))));
    if ~isempty(d)
        if length(d) == 1
            s = fullfile(d.folder, d.name);

        else
            % There are multiple filenames that match requested string.
            for i = 1:length(d)
                s{i} = fullfile(d(i).folder, d(i).name);
            end

            if length(s) > 1 && ~isempty('ofuse')
                idx = find(contains(s, ofuse));
                if length(idx) == 1
                    s = s{idx};

                elseif length(s) > 1
                    % This is imperfect -- 'ofuse' could also not exist in string at all...
                    error('Non-unique filename even using ''ofuse'' string -- make latter more specific')

                end
            else
                error('Non-unique filename -- try including ''ofuse'' string to narrow results to one')

            end
        end
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
    idx = cellstrfind(s, 'MER.*DET.*.sac');
    if isempty(idx)
        warning('No triggered (''DET'') SAC files found')
        s = [];
        return

    end

  case 'REQ'
    idx = cellstrfind(s, 'MER.*REQ.*.sac');
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
