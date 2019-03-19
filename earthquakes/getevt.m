function [revEQ, rawEQ, rawCP, rawPDF, rev_evt, raw_evt] = getevt(sac, diro, openpdf)
% [revEQ, rawEQ, rawCP, rawPDF, rev_evt, raw_evt] = GETEVT(sac, diro, openpdf)
%
% GETEVT returns the EQ structures built with sac2evt.m and winnowed
% (reviewed) with reviewevt.m.
%
% Inputs: 
% sac       SAC filename 
%               (def: '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
% diro      Path to directory containing 'raw/' and 'reviewed' 
%               subdirectories (def: $MERMAID/events/)
% openpdf   logical true to open raw PDFs
%
% Outputs:
% revEQ     Reviewed EQ structure returned by reviewevt.m 
% rawEQ     Raw EQ structure returned by sac2evt.m 
% rawCP     CP structure returned by cpsac2evt.m,
%              or NaN if the CP structure was not saved in *raw.evt
% rawPDF    Path to raw .pdfs returned by sac2evt.m
% rev_evt   Full path to reviewed .evt file, or [] if SAC not reviewed
% raw_evt   Full path to raw .evt file
%
% N.B. rawEQ = [] means that the SAC file was found not to match any
%              known earthquake in the catalog as queried by sac2evt.m.
%
%      revEQ = [] means that none of the possible events found by
%              sac2evt.m are matches after review with reviewevt.m
%
%      revEQ = NAN means this SAC file hasn't been reviewed 
%              (there exists no matching .evt file in the 'reviewed' directory)
%
% Before running the example below run the example in reviewevt.m
% 
% Ex: (retrieve reviewed EQ structure showing M4.8 P wave arrival)
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/sac2evt_example';
%    EQ  = GETEVT(sac, diro)
%
% See also: reviewevt.m, revsac.m, sac2evt.m, 
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Mar-2019, Version 2017b

% Defaults.
defval('sac', '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
defval('diro', fullfile(getenv('MERMAID'), 'events'))
defval('openpdf', false);

% Leave this -- do not wrap finding rev_evt and raw_evt into loop with
% a dynamically named structure or something of that nature because
% the path to the reviewed .evt is unknown without a recursive
% directory search, while the path to the raw .evt file is determined
% simply by 'diro'.  Ergo, a loop would be more work than necessary to
% find raw_evt because finding the two .evt files does not follow the
% same procedure.
sans_sac = strrep(strippath(sac), '.sac', '');
raw_evt = fullfile(diro, 'raw', 'evt', [sans_sac '.raw.evt']);
if ~exist(raw_evt, 'file') 
    error(sprintf('%s does not exist', raw_evt))
    
end

% Assign load.m output to variable for use in parfor loop.
tmp = load(raw_evt, '-mat');
rawEQ = tmp.EQ;
if isfield(tmp, 'CP')
    rawCP = tmp.CP;
    
else
    rawCP = [];

end
clear tmp

% Check if the event has been reviewed.  Use dir.m recursive search to
% look through 'identified/', 'unidentified/, and 'purgatory/'
% subdirectories in 'reviewed'.
rev_dir = dir(fullfile(diro, 'reviewed', '**/', 'evt', [sans_sac '.evt']));
if isempty(rev_dir)
    revEQ = NaN;
    rev_evt = [];

else
    rev_evt = fullfile(rev_dir.folder, rev_dir.name);
    tmp = load(rev_evt, '-mat');
    revEQ = tmp.EQ;
    clear tmp

end

% PDF paths.
corw = {'complete' 'windowed'};
for i = 1:length(corw)
    rawPDF{i} = fullfile(diro, 'raw', 'pdf', sprintf([sans_sac '.%s.raw.pdf'], corw{i}));
    if ~exist(rawPDF{i}, 'file') 
        error(sprintf('%s does not exist', rawPDF{i}))
        
    end
end

% Open the raw .pdfs, if requested.
if openpdf
    switch computer
      case 'GLNXA64'
        openpdf = 'evince %s &';

      case 'MACI64'
        openpdf = 'open -F %s';

      otherwise
        error(['\No known viewer .pdf for your system.  Update switch/case ' ...
               'block with preferred viewer.'])

    end
    for i = 1:length(corw)
        system(sprintf(openpdf, rawPDF{i}));
        
    end
end
