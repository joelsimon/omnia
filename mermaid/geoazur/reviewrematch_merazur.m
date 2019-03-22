function EQ = reviewrematch_merazur(sac, redo, diro)
% EQ = REVIEWREMATCH_MERAZUR(sac, redo, diro)
%
% Rapid, semi-manual 'review' of rematched raw .evt files as saved by
% rematch_merazur.m
%
% If the raw .evt file only includes a single EQ, or is empty, it is
% copied over in its entirety (all phases) to the
% [diro]/rematch/reviewed/identified folder.
%
% Otherwise, if the raw .evt file includes multiple EQs then the input
% SAC file is sent through the standard reviewevt.m procedure for
% manual review.
%
% NO SAC FILES ARE DEEMED "UNIDENTIFIED" -- being that the purpose of
% this is to compare against the GeoAzur catalog we report all events
% as identified, even if it's clearly incorrect.  I.e., the point of
% this is to pick a single EQ when multiple matched.
%
% Input:
% sac           SAC filename (def: 'm12.20130416T105310.sac')
% redo          logical true to delete any existing reviewed .evt 
%                   and rerun reviewevt.m on the input
%               logical false to skip redundant review (def: false)
% diro          Path to GeoAzur parent directory, fetched with fetch_mermaid
%                   (def: $MERAZUR)
% 
% Output:
% EQ        EQ structure after review
%
%
% Requires this directory, for JDS on linux:
%
%    mkdir $MERAZUR/rematch/reviewed/identified/evt
%
% This directory structure (the seemingly unnecessary 'identified'
% folder, when there will not exist and 'unidentified' counterpart)
% exists so that I can use reviewevt.m, which expects this form of
% directories.
%
% See also: reviewevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-Mar-2019, Version 2017b

% Defaults.
defval('sac', 'm12.20130416T105310.sac')
defval('redo', false)
defval('diro', getenv('MERAZUR'))

% Check if the .evt file associated with this SAC file has already been reviewed.
sac = fullsac(sac, diro);
sacname = strippath(sac);
rematch_diro = fullfile(diro, 'rematch');
[revEQ, rawEQ, ~, ~, rev_evt, raw_evt] = getevt(sac, rematch_diro); 
previously_reviewed = false;
if ~isempty(rev_evt) && ~redo
    fprintf('\n%s already reviewed\nSet ''redo'' to true to re-review\n', sacname)
    EQ = revEQ;
    return
    
end

% If the EQ structure is of length 1 or empty (*see note in header)
% it's identified.  In either case I don't want to look at it because
% I've already ensured I'm looking at the correct event thanks to the
% narrow search parameters or rematch_merazur.m
identified_diro = fullfile(rematch_diro, 'reviewed', 'identified');
if length(rawEQ) == 1 || isempty(rawEQ)
    rev_name = strrep(sacname, suf(sacname), 'evt');
    rev_evt = fullfile(identified_diro, 'evt', rev_name);
    copyfile(raw_evt, rev_evt);
    fprintf('\nCopied %s to %s\n\n', strippath(raw_evt), rev_evt);

else
    % Otherwise, look it over.
    EQ = reviewevt(sac, redo, rematch_diro)

end