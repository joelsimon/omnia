function writemermaidglobalcatalogall(incl_prelim)
%  WRITEMERMAIDGLOBALCATALOGALL(incl_prelim)
%
% Executes writemermaidglobalcatalog.m for magnitudes 4 though 9, assuming
% JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 16-Mar-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('globalfile', fullfile(getenv('MERMAID'), 'events', 'globalcatalog', 'M8.txt'));
defval('idfile', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('nfloats', 16)

p = fileparts(globalfile);
for i = 4:9
    writemermaidglobalcatalog(fullfile(p, sprintf('M%i.txt', i)), idfile, nfloats, incl_prelim);

end
