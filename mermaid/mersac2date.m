function tdate = mersac2date(sac)
% tdate = MERSAC2DATE(sac)
%
% Returns the UTC time of the first sample of a gen 3+ MERMAID
% (manufactured by Osean) SAC file written by automaid.
%
% MERSAC2DATE simply parses the SAC filename and returns precision in
% seconds. For milliseconds precision see seistime.m.
%
% Input:
% sac        MERMAID SAC filename (accepts cell arrays)
%
% Output:
% tdate      Datetime corresponding UTC time
%                of first sample of seismogram
%
% Ex:
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    tdate = MERSAC2DATE(sac)
%
% See also: seistime.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-Oct-2019, Version 2017b on GLNXA64

%% Recursive.

if iscell(sac)
    tdate = NaT(size(sac), 'TimeZone', 'UTC');
    for i = 1:length(sac)

        %% Recursive.

        tdate(i) = mersac2date(sac{i});

    end
    return

end

% Ensure proper input.
sac = strippath(sac);
if ~issac(sac)
    error('Input SAC filename only (must be char array ending in ''.SAC'' or ''.sac''')

end

% Convert filename string to datetime.
tstr = sac(1:15);
tstr(9) = []; % Remove 'T'
fmt = 'uuuuMMddHHmmss';
tdate = datetime(tstr, 'InputFormat', fmt, 'TimeZone', 'UTC');
