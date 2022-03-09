function fetchmerloc(locdir)
% FETCHMERLOC(locdir)
%
% Depreciated -- use `fetchesoloc`
%
% Pull MERMAID surfacing-location data off of EarthScopeOceans.org
% and save as local textfiles.
%
% Only retrieves Princeton-owned float information.
%
% Input:
% locdir   Directory to individual MERMAID textfiles
%              (default: $MERMAID/locations/)
%
% Author: Dr. Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 28-Aug-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

error('Depreciated -- use `fetchesoloc`')

defval('locdir', fullfile(getenv('MERMAID'), 'locations'));

[~, foo]  = mkdir(locdir);

floatstr = {'008' '009' '010' '011' '012' '013' '016' '017' '018' ...
            '019' '020' '021' '022' '023' '024' '025'};

for i = 1:length(floatstr)
    filename = fullfile(locdir, sprintf('P%s_all.txt', floatstr{i}));
    url = sprintf('http://geoweb.princeton.edu/people/simons/SOM/P%s_all.txt', floatstr{i});

    writeaccess('unlock', filename, false)
    websave(filename, url);
    writeaccess('lock', filename, false)

    fprintf('Updated %s\n', filename)

end
