function EQ = reviewrematch(sac, redo, diro)
% EQ = REVIEWREMATCH(sac, redo, diro)
%
% Rapid, semi-manual 'review' of rematched raw .evt files as saved by
% rematch.m
%
% If the raw .evt file only includes a single EQ it is copied over in
% its entirety (all phases) to the [diro]/reviewed/identified folder.
%
% If the raw .evt file is empty it is copied over in its entirety (all
% phases) to the [diro]/reviewed/unidentified folder.
%
% Otherwise, if the raw .evt file includes multiple EQs then the input
% SAC file is sent through the standard reviewevt.m procedure for
% manual review.
%
% Input:
% sac       SAC filename (def: 'm12.20130416T105310.sac')
% redo logical true to delete any existing reviewed .evt and rerun
%               reviewevt.m on the input
%           logical false to skip redundant review (def: false)
% diro      Path to directory containing 'raw/' and 'reviewed' 
%               subdirectories (def: $MERMAID/events/geoazur)
% 
% Output:
% EQ        EQ structure after review
%
% See also: reviewevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 19-Mar-2019, Version 2017b


% Defaults.
defval('sac', 'm12.20130416T105310.sac')
defval('redo', false)
defval('diro', fullfile(getenv('MERMAID'), 'events', 'geoazur'));

% Check if the .evt file associated with this SAC file has already been reviewed.
sacname = strippath(sac);
[revEQ, ~, ~, ~, rev_evt, raw_evt] = getevt(sac, diro); 
previously_reviewed = false;
if ~isempty(rev_evt) && ~redo
    fprintf('\n%s already reviewed\n', sacname)
    EQ = revEQ;
    return
    
end

% Load the raw evt file.
tmp = load(raw_evt, '-mat');
EQ = tmp.EQ;
clear tmp;

% If the EQ structure is empty it's unidentified; if it's of length 1
% it's identified.  In either case I don't want to look at it because
% I've already ensured I'm looking at the correct event thanks to the
% narrow search parameters.
rev_diro = fullfile(diro, 'reviewed');
rev_filename = strrep(sacname, suf(sacname), 'evt');

if isempty(EQ)
    rev_diro = fullfile(rev_diro, 'unidentified', 'evt');
    copyfile(raw_evt, fullfile(rev_diro, rev_filename));
    fprintf('Copied %s to unidentified\n', rev_filename)
    return

end

if length(EQ) == 1
    rev_diro = fullfile(rev_diro, 'identified', 'evt');
    copyfile(raw_evt, fullfile(rev_diro, rev_filename));
    fprintf('Copied %s to identified\n', rev_filename)
    return

end

% Otherwise, look it over.
EQ = reviewevt(sac, redo, diro)
