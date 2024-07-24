function [dtime, acq] = acqlog2date(acqlog)
% [dtime, acq] = ACQLOG2DATE(acqlog)
%
% Generate datetime and logical arrays of MERMAID acquisition started/stopped
% from acq_log.txt.
%
% ONLY 'acq started' (and not, e.g., 'acq already started') are true, while all
% other strings (e.g., 'acq [already] stopped' and '<ERR>acq not started') are false.
%
% Input:
% acqlog    Filename of acq_log.txt, written by `write_processed_acq_log`,
%              and likely saved in $MERMAID/processed/**/*
%
% Output:
% dtime     Datetime array of acquisition date strings
% acq       Logical array of trues iff 'acq started', e.g.:
%               'acq started' = true
%               'acq already started' = false
%               'acq stopped' = false
%               'acq already  stopped' = false
%               'acq not started' = false
%               '<ERR>acq not started' = false
%               ...and any other MERMAID decides to bless us with...
%
% Ex:
%    [dtime, acq] = ACQLOG2DATE('P0016_acq_log.txt')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Jul-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Read acq_log.txt into unformatted cell array (char lengths vary).
str = readtext(acqlog);

%% cellfun seems to process text much faster than loops...

% Extract date string: first 19 chars
dstr = cell2mat(cellfun(@(xx) xx(1:19), str, 'UniformOutput', false));
dtime = iso8601str2date(dstr, 1, true);

% Extract end of acquisition string: if last last 11 chars read "acq started"
% set state to true.
astr = cellfun(@(xx) xx(end-10:end), str, 'UniformOutput', false);
acq = strcmp(astr, 'acq started');

return

%% ___________________________________________________________________________ %%

% Leaving this here -- really slow loop version -- in case we actually want to
% match strings in the future and output more detail... actually this breaks
% with 467.174-T-0100 due to line '2023-10-20T10:11:35:<ERR>[MRMAID,0007]acq not
% started' where <ERR> comes before '[MERMAID*]', as opposed to after, in the
% Princeton MERMAIDS.

dtime = NaT(size(str), 'TimeZone', 'UTC');
acq = zeros(size(str));
for i = 1:length(str)
    % Extract date string and convert to datetime.  Split
    % '2018-09-05T00:14:00:[MRMAID,557]acq started' and keep
    % '2018-09-05T00:14:00'.
    dstr = fx(strsplit(str{i}, ':['), 1);
    dtime(i) = iso8601str2date(dstr, 1, true);

    % Extract acquisition "started" or "stopped".  Split
    % '2018-09-05T00:14:00:[MRMAID,557]acq started' and keep 'acq started'.
    astr = fx(strsplit(str{i}, ']'), 2);
    if strcmp(astr, 'acq started')
        acq(i) = 1;

    end

    % % Alternatively, if you every actually want the raw string?
    % switch astr
    %   case 'acq started'
    %     acq(i) = 1;
    %     %acqstr = 'started';

    %   case 'acq stopped'
    %     acq(i) = false;
    %     %acqstr = 'stopped';

    %   case '<ERR>acq not started'
    %     acq(i) = false;
    %     %acqstr = 'error';

    %   otherwise
    %     error('undefined acquisition string')

    % end
end
