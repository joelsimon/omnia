function cppt_sac = getcpptsac(id, otype, cpptdir)
% cppt_sac = GETCPPTSAC(id, otype, cpptdir)
%
% Return the SAC file(s) in [cpptdir]/sac/[id].
%
% Input:
% id          IRIS public event identification number
%                 (def: 10932551)
% otype       CPPT SAC file output type
%             []: (empty) return raw time series (def)
%             'none': return displacement time series (nm)
%             'vel': return velocity time series (nm/s)
%             'acc': return acceleration time series (nm/s/s)
% cpptdir     Path to directory containing CPPT stations
%                 'sac/' and 'evt/' subdirectories
%                 (def: $MERMAID/events/cpptstations/)
%
% Output:
% cppt_sac   Cell array of SAC files from CPPT stations
%
% See also: getcpptsacevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 30-Jan-2020, Version 2017b on GLNXA64

% Defaults.
defval('id', '10932551')
defval('otype', [])
defval('cpptdir', fullfile(getenv('MERMAID'), 'events', 'cpptstations'))

% This is just a wrapper for getnearbysac with the appropriate paths.
cppt_sac = getnearbysac(id, otype, cpptdir);
