function [cppt_EQ, cppt_evt] = getcpptevt(id, cpptdir)
% [cppt_EQ, cppt_evt] = GETCPPTEVT(id, cpptdir)
%
% Return the EQ structures(s) in [cpptdir]/evt/[id].
%
% Input:
% id         IRIS public event identification number
%                (def: 10932551)
% cpptdir    Path to directory containing cppt stations
%                'sac/' and 'evt/' subdirectories
%                (def: $MERMAID/events/cpptstations/)
%
% Output:
% cppt_EQ    Cell array of EQ structures related to CPPT
%                stations' SAC files
% cppt_evt   Full path to .mat file containing cppt_EQ
%
% See also: getcpptsacevt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 31-Jan-2020, Version 2017b on MACI64

% Defaults.
defval('id', '10932551')
defval('cpptdir', fullfile(getenv('MERMAID'), 'events', 'cpptstations'))

% This function is simply a wrapper for getnearbyevt.m.
[cppt_EQ, ~, cppt_evt] = getnearbyevt(id, cpptdir);
