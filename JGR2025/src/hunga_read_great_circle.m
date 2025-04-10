function gc = hunga_read_great_circle
% gc = HUNGA_READ_GREAT_CIRCLE
%
% Reads COARSE (15 km sampling) great-circle structure without GEBCO elevations
% from "hunga_write_great_circle.mat"
%
% Output:
% gc struct with fields ->
%    evla: event latitude [decimal degrees]
%    evlo: event longitude [decimal degrees]
%    stla: station latitude [decimal degrees]
%    stlo: station longitude [decimal degrees]
%    stdp: station depth [m; sea-level is 0, down is positive]
%    gcla: great-circle track latitudes [decimal degrees]
%    gclo: great-circle track longitudes [decimal degrees]
%    tot_distkm: total great-circle (epicentral) distance [km]
%    cum_distkm: cumulative (at each lat/lon) great-circle (epicentral) distance [km]
%    tot_distdeg: total great-circle (epicentral) distance [degrees]
%    cum_distdeg: cumulative (at each lat/lon) great-circle (epicentral) distance [degrees]
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 14-Mar-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

hundir = getenv('HUNGA');
savefile = fullfile(hundir, 'code', 'static', 'hunga_write_great_circle.mat');
tmp = load(savefile);
gc = tmp.gc;
