function [dtime, acq] = acqlog2date(acqlog)
% [dtime, acq] = ACQLOG2DATE(acqlog)
%
% Generate datetime and logical arrays of MERMAID acquisition started/stopped
% from acq_log.txt.
%
% Input:
% acqlog    Filename of acq_log.txt, written by `write_processed_acq_log`,
%              and likely saved in $MERMAID/processed/**/*
%
% Output:
% dtime     Datetime array of acquisition date strings
% acq       Logical array of acquisition state --
%              true: 'acq started'
%                    'acq already started'
%                    'acq not stopped'
%              false: 'acq stopped'
%                     'acq already stopped'
%                     'acq not started'
%                     ...and any other MERMAID decides to bless us with...
%
% Ex:
%    [dtime, acq] = ACQLOG2DATE('P0016_acq_log.txt')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 24-Jul-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Read acq_log.txt into unformatted cell array (char lengths vary).
str = readtext(acqlog);

% Extract date string: first 19 chars
dstr = cell2mat(cellfun(@(xx) xx(1:19), str, 'UniformOutput', false));
dtime = iso8601str2date(dstr, 1, true)

% Extract end of acquisition string: if last last 11 chars read "acq started",
% "acq alre[ady started]", or "acq [not stopped]" set state to true.
astr = cellfun(@(xx) xx(end-10:end), str, 'UniformOutput', false);
acq = strcmp(astr, 'acq started') + strcmp(astr, 'ady started') + strcmp(astr, 'not stopped')
