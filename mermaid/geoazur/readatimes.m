function varargout = readatimes
% [sacf, ph, trav_time, ga_time, jd_time, fs] = READATIMES
%
% READATIMES outputs the parsed information from
% $MERTXT/arrivaltimes.m, useful for gatres.m.  Hardcoded for
% arrivaltime file; change internally if necessary.  There are no
% inputs.
%
% See also: gatres.m, writeatimes.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 18-Jan-2019, Version 2017b

% Open.
afile = fullfile(getenv('MERAZUR'), 'textfiles', 'arrivaltimes.txt');
fid = fopen(afile, 'r');

% Write a line of arrival time information.
fmt = ['%23s '   ...                 % 1
       '%8s '    ...                 % 2
       '%7.2f '  ...                 % 3
       '%6.2f '  ...                 % 4
       repmat('%6.2f ',  [1 6])  ... % 5-10
       '%2u\n'];                     % 11

% Read it.
lynes = textscan(fid, fmt);

% Parse.
sacf = lynes{1};
ph = lynes{2};
trav_time = lynes{3};
ga_time = lynes{4};
jd_time = [lynes{5:10}];
fs = lynes{11};

% Collect output.
outargs = {sacf, ph, trav_time, ga_time, jd_time, fs};
varargout = outargs(1:nargout);

% Print some useful fact.
fprintf('Lines read in %s: %i\n', afile, length(lynes{1}));

scales = {'d1' 'd2' 'd3' 'd4' 'd5' 'a5'};
for j = 1:6
    % No arrival is marked with NaN in jd_time either because the SNR < 1,
    % or there is no sensitivity at that frequency (5 Hz SAC files
    % have no sensitivity at 8 and 4 Hz).
    no_arr = sum(isnan(jd_time(:, j)));
    fprintf('Number no arrival at scale %s:%i.\n', scales{j}, no_arr)
    
end

fprintf('Total number of 20 Hz records: %i.\n', length(find(fs == 20)))
fprintf('Total number of 5 Hz records: %i.\n', length(find(fs == 5)))
