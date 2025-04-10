function C = catsac(kstnm)
% C = CATSAC
%
% Return signal cateogry based on KSTNM.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 05-Dec-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Peaky
kstnm = {'P0054'
         'P0045'
         'P0042'
         'P0048'
         'P0041'
         'P0053'
         'P0023'
         'P0040'
         'N0002'
         'N0001'
         'H11S2'
         'H11S3'
         'H11S1'
         'H11N3'
         'H11N1'
         'H11N2'
         'H03S3'
         'H03S2'
         'H03S1'
         'H03N2'
         'H03N1'};

for i = 1:length(kstnm)
    C.(kstnm{i}) = 'A';

end

% Blobby
kstnm = {'P0028'
         'P0026'
         'P0036'
         'P0016'
         'P0022'
         'P0017'
         'P0021',
         'N0004'};

for i = 1:length(kstnm)
    C.(kstnm{i}) = 'B';

end

% Nonexistent (and/or indeterminate, or ignored for HTHH like P0057 amd R0073)
kstnm = {'P0049'
         'P0035'
         'P0025'
         'P0018'
         'P0019'
         'N0005'
         'P0057'
         'R0073'};

for i = 1:length(kstnm)
    C.(kstnm{i}) = 'C';

end
