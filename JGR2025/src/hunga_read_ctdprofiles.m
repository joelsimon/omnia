function [depth, vp, rho, salt, temp] = hunga_read_ctdprofiles(kstnm, mtype)
% [depth, vp, rho, salt, temp] = HUNGA_READ_CTDPROFILES(kstnm, mtype)
%
% Input: 
% kstnm       Five character station name
% mtype       Mode type/boundary conditions -
%              1: average_ocdp_PREM
%              2: local_ocdp_PREM
%              3: local_ocdp_PREMVpRho_Vs1000
%              4: local_ocdp_PREMVpRho_Vs2000
%              5: local_ocdp_Vp3Rho2pt5Vs0
%              6: local_ocdp_Vp4Rho3Vs0
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 06-Mar-2025, 24.1.0.2568132 (R2024a) Update 1 on MACA64 (geo_mac)

% Identify modes/ subdirectory.
switch mtype
  case 1
    mstr = 'average_ocdp_PREM';
    
  case 2
    mstr = 'local_ocdp_PREM';
    
  case 3
    mstr = 'local_ocdp_PREMVpRho_Vs1000';

  case 4
    mstr = 'local_ocdp_PREMVpRho_Vs2000';

  case 5
    mstr = 'local_ocdp_Vp3Rho2pt5Vs0';

  case 6
    mstr = 'local_ocdp_Vp4Rho3Vs0';

end

% Name it. (e.g., './P0045/mode_1_2.50Hz.txt')
staticdir = fullfile(getenv('HUNGA'), 'code', 'static', 'modes', mstr);
fname = fullfile(staticdir, kstnm, 'average1D_VpRhoTS.txt');

% Read it.
fid = fopen(fname, 'r');
C = textscan(fid, '%f %f %f %f %f', 'MultipleDelimsAsOne', true, 'Delimiter', ' ', ...
             'NumHeaderLines', 2);
fclose(fid);

% Parse it.
depth = C{1};
vp = C{2};
rho = C{3};
salt = C{4};
temp = C{5};
