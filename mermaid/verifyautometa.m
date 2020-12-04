function failed = verifyautometa(tol)
% failed = VERIFYAUTOMETA(tol)
%
% Reads automaid_metadata.csv, output by automaid v3.3+, and verifies that those
% text strings match the corresponding SAC header fields within a defined
% tolerance.
%
% Assumes JDS system defaults.
%
% Input:
% tol         Tolerance (def: 1e-6)
%
% Output:
% failed      Cell of SAC filenames that failed test
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Dec-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults
defval('S', [])
defval('tol', 1e-6)
if isempty(S)
    [~, S] = readautometa;

end

% Load list of all SAC files so you don't have to search for each within loop.
fs = fullsac;

% Compare 17 custom SAC header fields filled by automaid.
field = {'KNETWK',
         'KSTNM',
         'KCMPNM',
         'STLA',
         'STLO',
         'STEL',
         'STDP',
         'CMPAZ',
         'CMPINC',
         'KINST',
         'SCALE',
         'USER0',
         'USER1',
         'USER2',
         'USER3',
         'KUSER0',
         'KUSER1'};

% Initialize output, counter, and flag.
failed = {};
count = 0;
bad = false;

% Loop over every line of every automaid_metadata.csv file (for every MERMAID)
% and test the equality (within a defined tolerance) of what is written there in
% ASCII with the binary header fields in the corresponding .sac file.
mermaid = fieldnames(S);
for i = 1:length(mermaid)
    C = S.(mermaid{i});

    for j = 1:length(C.filename)
        count = count + 1;

        % Retrieve full path filename from list and read the SAC header.
        [~, sac] = cellstrfind(fs, C.filename{j});
        sac = sac{:};
        [~, H] = readsac(sac);

        % Loop over every header field written to automaid_metadata.csv
        for k = 1:length(field)
            csv = C.(field{k}){j}; % from ASCII .csv file
            bin = H.(field{k});    % from binary .sac file

            % If the SAC header is a float, compare within defined tolerance.
            % Otherwise compare string directly.
            if ~ischar(bin)
                if abs(str2double(csv)-bin) >= tol
                    bad = true;
                end
            else
                if ~strcmp(csv, bin)
                    bad = true;

                end
            end

            % Quit loop over SAC header fields prematurely if any do not match
            % .csv file.
            if bad
                failed = [failed ; sac];
                fprintf('!!! Failed: %s\n', sac);
                keyboard
                continue

            end
        end

        % The fields defined in this LINE of the ASCII .csv file match (within
        % tolerance) the values in the corresponding binary .sac file.
        if ~bad
            fprintf('Passed: %s\n', sac)

        end
    end
end

% Concluding remarks.
fprintf('Tolerance: %e\nTested: %i\nFailed: %i\n', tol, count, length(failed))
