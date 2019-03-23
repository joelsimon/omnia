function [CP, filename] = writechangepoint(fname, diro, domain, x, ...
                                           n, delta, pt0, snrcut, ...
                                           inputs, conf, fml);
% [CP, filename] = WRITECHANGEPOINT(fname, diro, domain, x, n, ...
%                                   delta, pt0, snrcut, inputs, conf, fml);
%
% Writes the CP structure, output from changepoint.m, to a '-mat' file
% named [diro]/[fname].cp.
%
% Input:
% diro             Directory where .cp file is to be saved 
% fname            Filename to append .cp extension
% domain,...,fml   Inputs changepoint.m, see there
%
% Output:
% CP               Output of changepoint.m, see there
% filename         Filename of .cp file
%
% Before running example below, make the required directory, for JDS
% on Linux:
%
%    mkdir $MERMAID/events/changepoints
%
% Ex:
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    [x, h] = readsac(sac);
%    fname = strrep(sac, '.sac', '');
%    diro = fullfile(getenv('MERMAID'), 'events', 'changepoints');
%    domain = 'time'; n = 5; delta = h.DELTA; pt0 = h.B;
%    snrcut = 1; inputs = cpinputs; conf = -1; fml = [];
%    [CP, filename] = WRITECHANGEPOINT(fname, diro, domain, x, n, ...
%                                      delta, pt0, snrcut, inputs, conf, fml);
%
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 23-Mar-2019, Version 2017b

% Default the uncommonly used input, 'fml'.
defval('fml', [])

% Compute and save.
CP = changepoint(domain, x, n, delta, pt0, snrcut, inputs, conf, fml);
filename = fullfile(diro, [fname '.cp']);
save(filename, 'CP', '-mat')