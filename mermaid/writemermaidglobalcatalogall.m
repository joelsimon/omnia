function writemermaidglobalcatalogall
%  WRITEMERMAIDGLOBALCATALOGALL
%
% Executes writemermaidcatalog.m for magnitudes 4 though 9, assuming
% JDS system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 07-Oct-2019, Version 2017b on MACI64

defval('globalfile', fullfile(getenv('MERMAID'), 'events', 'globalcatalog', 'M8.txt'));
defval('idfile', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'identified.txt'))
defval('nfloats', 16)

p = fileparts(globalfile);
for i = 4:9
    writemermaidglobalcatalog(fullfile(p, sprintf('M%i.txt', i)));

end
