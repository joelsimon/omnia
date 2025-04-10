function gc = hunga_read_great_circle_gebco
% gc = HUNGA_READ_GREAT_CIRCLE_GEBCO
%
% Return GEBCO-elevation structure for all MERMAIDs along great-circle tracks
% from HTHH to each station.
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
%    gebco_elev: GEBCO elevation [m; sea-level is 0, down is negative]
%
% Ex:
%    gc = HUNGA_READ_GREAT_CIRCLE_GEBCO
%    plot(gc.N0001.cum_distkm, gc.N0001.gebco_elev / 1000)
%    xlabel('distance [km]'); ylabel('elevation [km]')
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 29-Feb-2024, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

defval('matdir', fullfile(getenv('HUNGA'), 'code', 'static'));
fname = fullfile(matdir, 'hunga_write_great_circle_gebco.mat');
tmp = load(fname);
gc = tmp.gc;