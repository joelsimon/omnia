% Returns a list of unique phases, 'ga_phases', in the public MERMAID
% catalog, according to the 'events.txt' file.
%
% Also checks to make sure the event lines in the individual float
% files, 'm??_events.txt', match the lines in the global event file,
% 'events.txt'
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 03-Jun-2019, Version 2017b

% Fetch filenames of all identified GeoAzur MERMAID SAC files. 
sacfile = mermaid_sacf('id');

% Event file #1 is the global 'events.txt'  catalog.
evtfile1 = fullfile(getenv('MEREVENTS'), 'events.txt');

% Loop over every SAC file.
for i = 1:length(sacfile)
    s = strippath(sacfile{i});
    floatnum = s(2:3);

    % Event file #2 is the 'm??_events.txt' file in the individual floats'
    % subdirectory, where ?? is the float number (e.g.,
    % 'm16_events.txt').
    evtfile2 = fullfile(getenv('MERAZUR'), 'events', ...
                       sprintf('mermaid%s/m%s_events.txt', floatnum, floatnum));

    
    % Fetch the event lines out the different files and ensure they are identical.
    [~, evtline1] = mgrep(evtfile1, s);
    [~, evtline2] = mgrep(evtfile2, s);
    if ~strcmp(evtline1, evtline2)
        error('Event lines do not match')
        
    end

    % Parse phase from matching line in 'events.txt'.
    ga_phases{i} = purist(strtrim(evtline1{1}(103:110)));

end
