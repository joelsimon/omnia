function [iseq, field] = eqdiff(EQ1, EQ2)
% [iseq, field] = EQDIFF(EQ1, EQ2)
%
% Compare EQ structures.
%
% Return first fieldname that differs outside of acceptable tolerance of 1e-6
% (seconds, degrees [~1/10 m], radians etc.).
%
% Input:
% EQ1/2     Earthquake structures to compare
%
% Output:
% iseq      true if relevant fields, substruct fields equal within tolerance
% field     First fieldname found to differ, or [] if EQs equal
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Sep-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

tol = 1e-6;

EQ1 = rmfield(EQ1, 'QueryTime');
EQ2 = rmfield(EQ2, 'QueryTime');

% If they are equal you're done.
if isequaln(EQ1, EQ2)
    iseq = true;
    field = [];
    return

end
iseq = false;

% If they correspond to different events you're done
if ~strcmp(EQ1.PublicId, EQ2.PublicId)
    field = 'PublicId';
    return

end

%% Check the earthquake metadata (provided by IRIS) first.
fn1 = fieldnames(EQ1);
fn2 = fieldnames(EQ1);
if ~isequal(fn1, fn2)
    error('fieldnames differ...cannot faithfully compare EQ structs')

else
    fn = fn1;

end
for i = 1:length(fn)
    field = fn{i};

    % Skip the arrival metadata for now (that's handled in a latter loop).
    if strcmp(field, 'TaupTimes')
        continue

    end

    % Skip irrelevant substructs; we really only care about the "Preferred" values.
    if contains(field, {'Magnitudes' 'Origins' 'Params'})
        continue

    end

    if ~isequaln(EQ1.(field), EQ2.(field))
        return

    end
end

%% Check the arrival (computed by $OMNIA) metadata second.
fn1 = fieldnames(EQ1.TaupTimes);
fn2 = fieldnames(EQ1.TaupTimes);
if ~isequal(fn1, fn2)
    error('fieldnames differ...cannot faithfully compare EQ structs')

else
    fn = fn1;

end

fn = fieldnames(EQ1.TaupTimes);
for i = 1:length(EQ1.TaupTimes)
    for j = 1:length(fn)
        field = fn{j};

        a = EQ1.TaupTimes(i).(field);
        b = EQ2.TaupTimes(i).(field);

        if isequal(a, b)
            continue

        end

        switch class(a)
          case "double"
            if abs(a - b) > 1e-6
                return

            end

          case "datetime"
            if abs(seconds(a - b)) > 1e-6
                return

            end
        end
    end
end

% Maybe not exactly equal, but close enough within acceptable tolerance.
iseq = true;
field = [];
