% N.B.: the wget call in RASfetch is known to hang and/or incorrectly
% write the fist .xml file, ergo, this function make not perform as
% expected every time.
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Nov-2019, Version 2017b on GLNXA64


defval('txtfile', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'nearbystations.txt'))
defval('sacpzdir', fullfile(getenv('MERMAID'), 'events', 'nearbystations', 'sacpz'))

[~, foo] = mkdir(sacpzdir);

[net, sta] = parsenearbystations(txtfile);

for i = 1:length(network)
    if strcmp(network{i}, 'AM')
        system(sprintf('$OMNIA/mermaid/nearbystations/RASPfetch %s %s', net{i}, sta{i}));
        movefile(sprintf('%s.%s.sacpz', net{i}, sta{i}), sacpzdir)
        
    end
end

