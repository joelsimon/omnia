function [mer_sac, mer_EQ, cppt_sac, cppt_EQ] = ...
    getcpptsacevt(id, mer_evtdir, mer_sacdir, cpptdir, check4update, returntype, otype)
% [mer_sac, mer_EQ, cppt_sac, cppt_EQ] = ...
%      GETCPPTSACEVT(id, mer_evtdir, mer_sacdir, cpptdir, check4update, returntype, otype)
%
% GETCPPTSACEVT returns SAC filenames and EQ structures corresponding
% to an input event ID for MERMAID and CPPT seismic stations.
%
% SAC files and EQ structures associated with CPPT stations are only
% returned if corresponding MERMAID data exist for that event ID, for
% that returntype (see Ex2).  To return CPPT SAC or EQ information
% regardless of that datas' existence in the MERMAID record, see
% getcpptsac.m and getcpptevt.m.
%
% Input:
% id            Event identification number in last
%                   column of identified.txt (def: 10932551)
% mer_evtdir    Path to directory containing MERMAID 'raw/' and 'reviewed'
%                   subdirectories (def: $MERMAID/events/)
% mer_sacdir    Path to directory to be (recursively) searched for
%                   MERMAID SAC files (def: $MERMAID/processed/)
% cpptdir       Path to directory containing CPPT stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/cpptstations/)
% check4update  true verify EQ metadata does not differ across EQ structures
%                   (def: true; see need2updateid.m)
% returntype    For third-generation+ MERMAID only:
%               'ALL': both triggered and user-requested SAC files (def)
%               'DET': triggered SAC files as determined by onboard algorithm
%               'REQ': user-requested SAC files
% otype         CPPT SAC file output type, see rmcpptresp.m
%               []: (empty) return raw time series (def)
%               'none': return displacement time series (nm)
%               'vel': return velocity time series (nm/s)
%               'acc': return acceleration time series (nm/s/s)
%
% Output:
% mer_sac       Cell array of MERMAID SAC files
% mer_EQ        Reviewed EQ structures for each MERMAID SAC file
% cppt_sac      Cell array of SAC files from CPPT stations
% cppt_EQ       Cell array of EQ structures related to CPPT
%                   stations' SAC files
% Ex1:
%    [mer_sac, mer_EQ, cppt_sac, cppt_EQ] = ...
%      GETCPPTSACEVT('10932551')
%
% Ex2: (CPPT .evt data, though they exist, are not returned because there are
%       no requested ('REQ') MERMAID SAC files associated with this event ID)
%    [a, b, c, d] = GETCPPTSACEVT('10932551', [], [], [], [], 'DET')
%    [a, b, c, d] = GETCPPTSACEVT('10932551', [], [], [], [], 'REQ')
%
% See also: requestcppttraces.m, cpptsac2evt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 31-Jan-2020, Version 2017b on MACI64

% Defaults.
defval('id', '10932551')
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('cpptdir', fullfile(getenv('MERMAID'), 'events', 'cpptstations'))
defval('check4update', true)
defval('returntype', 'ALL')
defval('otype', [])

% This function is simply a script for getnearbysacevt.m; supply
% 'cpptsac2evt.m' as undocumented input there for proper warnings
% (see postscript note there).
[mer_sac, mer_EQ, cppt_sac, cppt_EQ] = ...
    getnearbysacevt(id, mer_evtdir, mer_sacdir, cpptdir, check4update, returntype, otype, 'cpptsac2evt');
