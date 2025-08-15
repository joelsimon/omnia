function identify_redundant_data()
% IDENTIFY_REDUNDANT_DATA
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Oct-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc
sacdir = fullfile(getenv('HUNGA'), 'sac');
um_sacdir = fullfile(sacdir, 'unmerged');
sac = globglob(um_sacdir, '*MER*.sac');

for i = 1:length(sac)
    x{i} = readsac(sac{i});

end

list = [];
for i = 1:length(sac)
    for j = 1:length(sac)
        if i == j
            continue
        end
        if isequal(x{i}, x{j})
            sij = sort([i j]);
            if ~any(ismember(list, sij))
                fprintf('%s\n', strippath(sac{i}))
                fprintf('%s\n\n', strippath(sac{j}))
                list = [list ; sij];

            end
        end
    end
end
