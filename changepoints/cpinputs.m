function inputs = cpinputs
% inputs = CPINPUTS
%
% CPINPUTS returns a structure of default parameters, used as input for
% changepoint.m, with fields
%
% For wtrmedge.m
%      tipe: 'CDF'
%       nvm: [2 4]
%       pph: 4
%     intel: 0
%    rmedge: true
%
% For wtsnr.m
%      meth: 1
%
% For cpest.m (and cpci.m)
%      algo: 'fast'
%     dtrnd: false;
%      bias: true
%    cptype: 'kw'
%
% For cpci.m
%     iters: 1e3
%    alphas: [0:.5:10]
%     dists: {'norm','norm'}  
%   stdnorm: false
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 04-Feb-2019, Version 2017b

inputs.tipe = 'CDF';
inputs.nvm = [2 4];
inputs.pph = 4;
inputs.intel = 0;
inputs.rmedge = true;
inputs.meth = 1;
inputs.algo = 'fast';
inputs.dtrnd = false;
inputs.bias = true;
inputs.cptype = 'kw';
inputs.iters =  1e3;
inputs.alphas = [0:.5:10];
inputs.dists =  {'norm','norm'};
inputs.stdnorm = false;
