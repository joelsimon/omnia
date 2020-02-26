function iddirmatch(ddir, id)
% IDDIRMATCH(ddir, id)
%
% Throws error if the lists of *.SAC* and *.evt file do not match.
%
% N.B. no check is performed to ensure those directories exist.
%
% Input:
% ddir     Directory containing 'sac' and 'evt' subdirectories
%              (def: $MERMAID/events/nearbystations)
% id       IRIS public event ID (def: 10932551)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 26-Feb-2020, Version 2017b on GLNXA64

defval('ddir', fullfile(getenv('MERMAID'), 'events', 'nearbystations'))
defval('id', '10932551')

id = num2str(id);
sacpath = fullfile(ddir, 'sac', id);
evtpath = fullfile(ddir, 'evt', id);

% Event files.
evt = recursivedir(dir(fullfile(evtpath, '**/*.evt')));
evt = cellfun(@(xx) strippath(xx), evt, 'UniformOutput', false);
evt = cellfun(@(xx) xx(1:end-4), evt, 'UniformOutput', false);

% Raw SAC files
sac = recursivedir(dir(fullfile(sacpath, '**/*.SAC')));
sac = cellfun(@(xx) strippath(xx), sac, 'UniformOutput', false);
sac = cellfun(@(xx) xx(1:end-4), sac, 'UniformOutput', false);
if ~isequal(sac, evt)
        error('*.SAC and *.evt file lists differ:\n    %s\n    %s\n', sacpath, evtpath)

end

% Displacement SAC files (if they exist).
none = recursivedir(dir(fullfile(sacpath, '**/*.none')));
if ~isempty(none)
    none = cellfun(@(xx) strippath(xx), none, 'UniformOutput', false);
    none = cellfun(@(xx) xx(1:end-9), none, 'UniformOutput', false);
    if ~isequal(none, evt)
        error('*.SAC.none and *.evt file lists differ:\n    %s\n    %s\n', sacpath, evtpath)
    end
end

% Velocity SAC files (if they exist).
vel = recursivedir(dir(fullfile(sacpath, '**/*.vel')));
if ~isempty(vel)
    vel = cellfun(@(xx) strippath(xx), vel, 'UniformOutput', false);
    vel = cellfun(@(xx) xx(1:end-8), vel, 'UniformOutput', false);
    if ~isequal(vel, evt)
        error('*.SAC.vel and *.evt file lists differ:\n    %s\n    %s\n', sacpath, evtpath)

    end
end

% Acceleration SAC files (if they exist).
acc = recursivedir(dir(fullfile(sacpath, '**/*.acc')));
if ~isempty(acc)
    acc = cellfun(@(xx) strippath(xx), acc, 'UniformOutput', false);
    acc = cellfun(@(xx) xx(1:end-8), acc, 'UniformOutput', false);
    if ~isequal(acc, evt)
        error('*.SAC.acc and *.evt file lists differ:\n    %s\n    %s\n', sacpath, evtpath)

    end
end

fprintf('Lists of SAC* and evt files match:\n    %s\n    %s\n', sacpath, evtpath)
