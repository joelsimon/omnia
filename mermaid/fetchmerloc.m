function fetchmerloc(locdir)
% FETCHMERLOC(locdir)
%
% Pull MERMAID surfacing-location data off of EarthScopeOceans.org
% and save as local textfiles.
%
% Only retrieves Princeton-owned float information.
%
% Input:
% locdir   Directory to individual MERMAID textfiles
%              (defval: $MERMAID/locations/)
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 13-Jan-2020, Version 2017b on GLNXA64

defval('locdir', fullfile(getenv('MERMAID'), 'locations'));

[~, foo]  = mkdir(locdir);

floatstr = {'008' '009' '010' '011' '012' '013' '016' '017' '018' ...
            '019' '020' '021' '022' '023' '024' '025'};

for i = 1:length(floatstr)
    filename = fullfile(locdir, sprintf('P%s_all.txt', floatstr{i}));
    url = sprintf('http://geoweb.princeton.edu/people/simons/SOM/P%s_all.txt', floatstr{i});

    writeaccess('unlock', filename, false)
    websave(filename, url)
    writeaccess('lock', filename, false)

end
