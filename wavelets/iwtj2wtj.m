function [xja, xjd] = iwtj2wtj(xj)
% [xja, xjd] = iwtj2wtj(xj)
%
% IWTJ2WTJ parses the first output of iwt.m (partial reconstructions
% of an input time series) into its approximation (scaling) and detail
% (wavelet) coefficients in the same order as output from wt.m.
%
% iwt.m outputs x_j, an n + 1 cell of partial reconstructions of x where:
%     j = 1: approximations at coarsest resolution (a in wt.m)
%     j = 2: details at the coarsest resolution (d{n} in wt.m)
%     j = n: details at the finest resolution (d{1} in wt.m)
%
% Input:
% xj     First output of iwt.m (there, called 'x')
%
% Output:
% xja     Partial reconstruction of x using only approximation
%             (j = J) coefficients at the coarsest scale
% xjd     Partial reconstruction of x using only detail
%             (j = [1,...,J) coefficients, where d{1} is finest
%             and d{n} is coarsest resolution
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 16-Nov-2018, Version 2017b

xja = xj{1};
xjd = flip(xj(2:end));
