function [sac, evt] = psac(iup, sacdir, revdir)
% [sac, evt] = PSAC(iup, sacdir, revdir)
%
% PSAC is revsac considering ONLY Princeton MERMAIDS (P-08 thru P-25).
%
% PSAC returns a list of fullpath Princeton .sac and .evt filenames
% whose event information has been reviewed and sorted with
% reviewevt.m into either:
%
% [revdir]/reviewed/identified/evt,
% [revdir]/reviewed/unidentified/evt, or
% [revdir]/reviewed/purgatory/evt.
%
% Input:
% iup       [revdir]/reviewed/ directory (def: 1)
%           1 identified
%          -1 unidentified
%           0 purgatory
% sacdir    Directory where .sac files are kept
%                (def: $MERMAID/processed)
% revdir    Directory where .evt files are kept
%                (def: $MERMAID/events)
%
% Output:
% sac       Cell array of Princeton SAC filenames whose corresponding 
%               .evt file is in the reviewed subdirectory of interest
% evt       Cell array of Princeton .evt filenames whose corresponding 
%               in the reviewed subdirectory of interest
%           
% See also: revsac.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 07-Aug-2019, Version 2017b

% Defaults.
defval('iup', 1)
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('revdir', fullfile(getenv('MERMAID'), 'events'))

% Retrieve the list of ALL SAC files in that review category.
[all_sac, all_evt] = revsac(iup);

% Extract only SAC files containing substrings '-P-08/' through 'P-25/'.
[idx, sac] = cellstrfind(all_sac, '-P-(0[8-9]|1[0-9]|2[0-5])\/');
evt = all_evt(idx);