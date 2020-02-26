function [cppt_sac, new] = rmcpptresp(id, redo, otype, cpptdir, cpptpz, transcript, freqlimits)
% [cppt_sac, new] = RMCPPTRESP(id, redo, otype, cpptdir, cpptpz, transcript, freqlimits)
%
% Remove the instrument response for CPPT stations and save the
% corrected SAC file in the same directory with the output type appended.
%
% RMCPPTRESP requires the SAC program.
%
% Any existing SAC files removed, e.g., in the case of redo = true,
% are printed to the screen.*
%
% id         Event ID [last column of 'identified.txt']
%                defval('11052554')
% redo       true to delete* existing corrected SAC files and remake them
%                (def: false)
% otype      Transfer type in SAC: 'none', 'vel', or 'acc' (def)
% cpptdir    Path to directory containing CPPT stations
%                'sac/' and 'evt/' subdirectories
%                (def: $MERMAID/events/cpptstations/)
% cpptpz     Concatenated pole-zero file name
%                (def: $MERMAID/events/cpptstations/pz/cpptstations.pz)
% transcript Shell script detailing SAC transfer function
%                (def: $OMNIA/mermaid/nearbystations/nearbytransfer)
% freqlimits 1x4 array of freqlimits for SAC transfer in Hz
%                (def: [0.05 0.1 10 20])
% Output:
% cppt_sac    Cell array of corrected SAC files from CPPT stations
% new         logical true if corrected SAC generated fresh
%
% *git history, if it exists, is respected with gitrmdir.m.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Feb-2020, Version 2017b on GLNXA64

% Defaults.
defval('id', '11052554')
defval('redo', false)
defval('otype', 'acc')
defval('cpptdir', fullfile(getenv('MERMAID'), 'events', 'cpptstations'))
defval('cpptpz', fullfile(getenv('MERMAID'), 'events', 'cpptstations', 'pz', 'cpptstations.pz'))
defval('transcript', fullfile(getenv('OMNIA'), 'mermaid', 'nearbystations', 'nearbytransfer'))
defval('freqlimits', [0.05 0.1 10 20])

% This function is simply a wrapper for rmcpptresp.m, tailored here
% for CPPT stations instead of 'cppt' stations.
[cppt_sac, ~, new] = ...
      rmnearbyresp(id, redo, otype, cpptdir, cpptpz, transcript, freqlimits);
