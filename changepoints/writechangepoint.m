function [CP, filename] = writechangepoint(fname, diro, redo, domain, x, n, delta, pt0, snrcut, inputs, conf, fml);
% [CP, filename] = WRITECHANGEPOINT(fname, diro, redo, domain, x, n, delta, pt0, snrcut, inputs, conf, fml);
%
% Writes the CP structure, output from changepoint.m, to a '-mat' file
% named [diro]/[fname].cp.
%
% Input:
% diro             Directory where .cp file is to be saved 
% redo
% fname            Filename to append .cp extension
% domain,...,fml   Inputs changepoint.m, see there
%                      (all defaulted)
% Output
% CP               Output of changepoint.m, see there
% filename         Filename of .cp file
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-Mar-2019, Version 2017b

% Default the uncommonly used input, 'fml'
defval('fml', [])

% Compute and save.
CP = changepoint(domain, x, n, delta, pt0, snrcut, inputs, conf, fml);
save(fullfile(diro, [fname '.cp']), 'CP', '-mat')