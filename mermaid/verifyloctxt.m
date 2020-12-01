function failed = verifyloctxt(loc)
% failed = VERIFYLOCTXT(loc)
%
% Reads loc.txt, output by automaid v3.2+, and verifies that those text strings
% match the corresponding SAC header fields to the same decimal precision.
%
% Input:
% loc         Struct of raw loc.txt strings (def: readlocraw)
%
% Output:
% failed      Cell of SAC filenames that failed test
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Dec-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Default.
defval('loc', readlocraw)

% For each SAC file: read the binary header and convert their fields to
% 6-precision strings and compare that string with what is printed in loc.txt
failed = {};
name = fieldnames(loc);
parfor i = 1:length(name)
    L = loc.(name{i});

    for j = 1:length(L.file_name)
        sac = [L.file_name{j} '.sac'];

        [~, h] = readsac(fullsac(sac));
        H_stla = sprintf('%.6f', h.STLA);
        H_stlo = sprintf('%.6f', h.STLO);
        H_stdp = sprintf('%.0f', h.STDP);

        if ~strcmp(H_stla, L.stla{j}) || ~strcmp(H_stlo, L.stlo{j}) || ~strcmp(H_stdp, L.stdp{j})
            fprintf('!!! Failed: %s\n', sac)
            failed = [failed ; sac]

        else
            fprintf('Passed: %s\n', sac)

        end
    end
end
