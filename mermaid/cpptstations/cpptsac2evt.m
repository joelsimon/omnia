function cppt_EQ = cpptsac2evt(id, redo, mer_evtdir, mer_sacdir, cpptdir, model, ph, baseurl)
% cppt_EQ = CPPTSAC2EVT(id, redo, mer_evtdir, mer_sacdir, cpptdir, model, ph, baseurl)
%
% CPPTSAC2EVT runs sac2evt.m on all SAC files related to a single
% event ID contained in [cpptdir]/sac/[id], and saves the output EQ
% structures in .evt files in [cpptdir]/evt/[id].
%
% Any existing .evt files removed, e.g., in the case of redo = true,
% are printed to the screen.*
%
% Input:
% id            Event ID [last column of 'identified.txt']
%                   defval('11052554')
% redo          true to delete* existing [cpptdir]/evt/[id]/ .evt files and
%                   refetch .evt files with sac2evt.m (def: false)
% mer_evtdir    Path to directory containing MERMAID 'raw/' and 'reviewed/'
%                   subdirectories (def: $MERMAID/events/)
% mer_sacdir    Path to directory to be (recursively) searched for
%                   MERMAID SAC files (def: $MERMAID/processed/)
% cpptdir     Path to directory containing CPPT stations
%                   'sac/' and 'evt/' subdirectories
%                   (def: $MERMAID/events/cpptstations/)
% model         Taup model (def: 'ak135')
% ph            Taup phases (def: defphases)
% baseurl       1: 'http://service.iris.edu/fdsnws/event/1/' (def)
%               2: 'https://earthquake.usgs.gov/fdsnws/event/1/'
%               3: 'http://isc-mirror.iris.washington.edu/fdsnws/event/1/'
%               4: 'http://www.isc.ac.uk/fdsnws/event/1/'
%
% *git history, if it exists, is respected with gitrmdir.m.
%
% Output:
% *N/A*    (writes reviewed .evt file)
% EQ       EQ structures for each 'CPPT' SAC file,
%             or [] if already fetched and redo not required
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 31-Jan-2020, Version 2017b on MACI64

% Defaults.
defval('id', '10932551')
defval('redo', false)
defval('mer_evtdir', fullfile(getenv('MERMAID'), 'events'))
defval('mer_sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('cpptdir', fullfile(getenv('MERMAID'), 'events', 'cpptstations'))
defval('model', 'ak135')
defval('ph', defphases)
defval('baseurl', 1);
cppt_EQ = {};

% This function is simply a wrapper for nearbysac2evt.m.
cppt_EQ = nearbysac2evt(id, redo, mer_evtdir, mer_sacdir, cpptdir, model, ph, baseurl);
