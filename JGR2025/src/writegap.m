function [gap, gap_mat] = writegap(sac2mergedsac_out)
% [gap, gap_mat] = WRITEGAP(sac2mergedsac_out)
%
% Read "sac2mergedsac_??/????.out", output of SAC merge, and save zero-filled
% gaps into MAT structure (in same directory) for easy interpolation.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 26-Aug-2022, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Read merge .out file.
c = readtext(sac2mergedsac_out);
n = regexp(c, 'merge: Gap zero fill: [n: (\d*) t:', 'tokens', 'once');
z = cell2mat(cellfun(@str2double, n, 'UniformOutput', false));

gap = [];
if ~isempty(z)
    % Identify gap start/stop from "merge: Gap zero fill: [n: 36000 ..."
    d = find(diff(z)~=1);
    if ~isempty(d)
        gap{1} = [z(1) z(d(1))];
        for i = 1:length(d)-1
            gap{i+1} = [z(d(i)+1) z(d(i+1))];

        end
        gap{length(d)+1} = [z(d(end)+1) z(end)];

    else
        gap{1} = [z(1) z(end)];

    end

    % Add 1 to gap start/stop because SAC indexes from 0.
    % (and timing, "t", is relative to h.B in "n: XXXXX t: XXXX])
    gap = cellfun(@(xx) xx+1, gap, 'UniformOutput', false);

end

% Save gaps to .mat file.
% "sac2mergedsac_01.out" -> "sac2mergedsac_01_gap.mat"
gap_mat = strrep(sac2mergedsac_out, '.out', '_gap.mat');
save(gap_mat, 'gap')

fprintf('Wrote %s\n', gap_mat)
