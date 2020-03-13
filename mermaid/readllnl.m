function [s, d3_d1, d1_tptime, d3_tptime, gcdiff, d1gc, watercorr, ph] = readllnl(filename)
% [s, d3_d1, d1_tptime, d3_tptime, gcdiff, d1gc, watercorr, ph] = READLLNL(filename)
%
% Reads textfile of 3D mantle corrections using LLNL-G3Dv3 w.r.t. 1D
% ak135, written by Jessica C. E. Irving.
%
% 3D-1D = LLNL-G3Dv3 with an underwater seismometer, elliptical earth, and 3D mantle and 3D crust -
%         ak135 with a surface seismometer on rock and a round 1D model
%
% Input:
% filename   Filename (def: $MERMAID/events/reviewed/identified/txt/llnl.txt)
%
% Output:
% s          SAC filename
% d3_d1      3D-1D travel time [s]
% d1_tpime   1D travel time [s]
% d3_tptime  3D travel time [s]
% gcdiff     Difference in path epicentral distance [degrees]
%                (3D-1D?)
% d1gc       1D epicentral distance [degrees]
% watercorr  LLnL water_corr (event side, source side, both?)
% ph         Phase name
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 12-Mar-2020, Version 2017b on GLNXA64

defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', 'identified', 'txt', 'llnl.txt'));

fmt = ['%s' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%f' ...
       '%f ' ...
       '%s'];

fid = fopen(filename, 'r');
c = textscan(fid, fmt, 'HeaderLines', 1, 'Delimiter', ' ');
fclose(fid);

s = c{1};
d3_d1 = c{2};
d1_tptime = c{3};
d3_tptime = c{4};
gcdiff = c{5};
d1gc = c{6};
watercorr = c{7};
ph = c{8};
