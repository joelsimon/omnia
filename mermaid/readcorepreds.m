function [s, PKIKP, PKPbc, PKiKP, PKPab, gcarc] = readcorepreds(mod)
% [s, PKIKP, PKPbc, PKiKP, PKPab, gcarc] = READCOREPREDS(mod)
%
% Reads text files of travel times for various core phases written by
% Jessica C.E. Irving.
%
% Input:
% mod               Model: 'ak135' (def), 'iasp91', or '3D' (LLNL-G3Dv3)
%
% Output:
% s, ..., PKPab     SAC filename and the theoretical travel time for various
%                       core phases per the model specified in the filename
% gcarc             Great circle distance if 'ak135' or 'iasp91'; NaN for 'llnl'
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu | joeldsimon@gmail.com
% Last modified: 27-Apr-2020, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('mod', 'ak135')

core_path = fullfile(getenv('SIMON2020_CODE'), 'data', 'jessica2');
if ~isempty(mod)
    switch lower(mod)
      case 'ak135'
        core_file = 'ak135_JessData_preds.out';

      case 'llnl'
        core_file = '3D_JessData_preds.out';

      case 'iasp91'
        core_file = 'iasp91_JessData_preds.out';

      otherwise
        error('Specific one of ''ak135'' ''iasp91'' or ''llnl')

    end
end
filename = fullfile(core_path, core_file);

if contains(filename, {'ak135', 'iasp91'})
    fmt = ['%s' ...
           '%f' ...
           '%f' ...
           '%f' ...
           '%f' ...
           '%f'];     % Extra field: great-circle distance (degrees)
else
    fmt = ['%s' ...
           '%f' ...
           '%f' ...
           '%f' ...
           '%f'];

end
fid = fopen(filename, 'r');

% The carriage-return ^M marks the end of line for these files. Specific '\r\n'
% to make them readable with textscan.
c = textscan(fid, fmt, 'HeaderLines', 1, 'Delimiter', ' ', 'EndOfLine', '\r\n');
fclose(fid);

% Parse output (-2 was used where phases arrivals do not theoretically exist).
s = c{1};
PKIKP = c{2}; PKIKP(PKIKP == -2) = NaN;
PKPbc = c{3}; PKPbc(PKPbc == -2) = NaN;
PKiKP = c{4}; PKiKP(PKiKP == -2) = NaN;
PKPab = c{5}; PKPab(PKPab == -2) = NaN;

% No great-circle distance is included with the 3D textfile.
if contains(filename, {'ak135', 'iasp91'})
    gcarc = c{6};

else
    gcarc = NaN(size(s));

end

return

%%______________________________________________________________________________________%%
% Extra verification to ensure my ak135 numbers computed in MatTaup match (for my notes).
[s, PKIKP, PKPbc, PKiKP, PKPab, gcarc] = readcorepreds('ak135');

for i = 1:length(s)
    EQ = getevt(s{i}); EQ = EQ(1);
    isbc = true;

    for j = 1:length(EQ.TaupTimes)
        ph_name = EQ.TaupTimes(j).phaseName;
        tr_time = EQ.TaupTimes(j).time;

        switch ph_name
          case 'PKIKP'
            jPKIKP(i) = tr_time;

          case 'PKP'
            if isbc
                jPKPbc(i) = tr_time;
                isbc = false;

            else
                jPKPab(i) = tr_time;

            end

          case 'PKiKP'
            jPKiKP(i) = tr_time;

        end
    end
    dgcarc(i) = EQ(1).TaupTimes(1).distance - gcarc(i);

end
dPKIKP = jPKIKP(:) - PKIKP;
dPKPbc = jPKPbc(:) - PKPbc;
dPKiKP = jPKiKP(:) - PKiKP;
dPKPab = jPKPab(:) - PKPab;

fprintf('Max. PKIKP difference: %.3f s\n', max(abs(dPKIKP)))
fprintf('Max. PKPbc difference: %.3f s\n', max(abs(dPKPbc)))
fprintf('Max. PKiKP difference: %.3f s\n', max(abs(dPKiKP)))
fprintf('Max. PKPab difference: %.3f s\n', max(abs(dPKPab)))
fprintf('Max. dist. difference: %.3f km\n', deg2km(max(abs(dgcarc))))
