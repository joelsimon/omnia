function fix_dmc_response
% FIX_DMC_RESPONSE
%
% Highlight discrepancies between G. Nolet's poles-zeros and those posted at
% the EarthScope DMC.
%
% June 2025 output:
%
% LINE  3: (second column)
%     DMC:  +0.000000e+00
%   NOLET:    0.48929E-01
%
% LINE  7: (first column)
%     DMC: -2.336880e-02
%   NOLET: -0.23688E-01
%
% LINE 10: (second column)
%     DMC:  +5.040500e-01
%   NOLET:    0.50405E-01
%
% LINE 13: (second column)
%     DMC:  -5.933400e-03
%   NOLET:    0.59334E-03

% LINE 16: (first column)
%     DMC: -5.839700e-01
%   NOLET: -0.58397E-01
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Jun-2025, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

clc

dmc = readtext('response/dmc.pz');
%dmc = readtext('response/dmc_fixed.pz');
nolet = readtext('response/nolet.pz');

for i = 1:length(dmc)
    if startsWith(dmc{i}, {'Z', 'P', 'C'})
        continue

    end
    ds = dmc{i};
    ns = nolet{i};

    dd = str2num(ds);
    nd = str2num(ns);

    wrong = (dd ~= nd);

    if wrong(1)
        fprintf('LINE %2i: (first column)\n', i)
        fprintf('    DMC: %14s\n', ds(1:14))
        fprintf('  NOLET: %14s\n\n', ns(1:14))

    end
    if wrong(2)
        fprintf('LINE %2i: (second column)\n', i)
        fprintf('    DMC: %14s\n', ds(15:end))
        fprintf('  NOLET: %14s\n\n', ns(15:end))

    end
end
