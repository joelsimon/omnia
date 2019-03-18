function varargout = readatimes2
% [sacf, ph, trav_time, ga_time, ga_snr, jd_time, ...
%             jd_snr, wlen, xlSecs, fs] = READATIMES2    
%
% READATIMES2 outputs the parsed information from
% $MERTXT/arrivaltimes2.m.  Hardcoded for arrivaltime2 file; change
% internally if necessary.  There are no inputs.
%
% See: $MERAZUR/textfiles/README_arrivaltimes.txt
%
% See writeatimes.m for I/0.
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 22-Aug-2018, Version 2017b

% Open.
afile = fullfile(getenv('MERAZUR'), 'textfiles', 'arrivaltimes2.txt');
fid = fopen(afile, 'r');

% Write a line of arrival time information.
fmt = ['%23s '   ...
       '%7s '    ...
       '%10.2f ' ...
       '%6.2f '  ...
       repmat('%11.5f ', [1 10]) ...
       repmat('%6.2f ', [1 5])  ...
       repmat('%11.5f ', [1 5])  ...
       repmat('%6.2f ', [1 5])  ...
       repmat('%11.5f ', [1 5])  ...
       repmat('%6.2f ', [1 2])  ...
       '%2u\n'];
    

% Data format. Note that textscan.m and fprintf.m don't have the same
% formatspec.  Even though I save in exponential notation (%e) I read
% in floating point (sparring loss of precision they are the same).

% Read it.
lynes = textscan(fid, fmt);

% Parse.
sacf = lynes{1};
ph = lynes{2};
trav_time = lynes{3};
ga_time = lynes{4};
ga_snr{1} = [lynes{5:9}];
ga_snr{2} = [lynes{10:14}];
jd_time{1} = [lynes{15:19}];
jd_snr{1} = [lynes{20:24}];
jd_time{2} = [lynes{25:29}];
jd_snr{2} = [lynes{30:34}];
wlen = lynes{35};
xlSecs = lynes{36};
fs = lynes{37};

% Collect output.
outargs = {sacf, ph, trav_time, ga_time, ga_snr, jd_time, jd_snr, ...
           wlen, xlSecs, fs};

varargout = outargs(1:nargout);

% Print some useful fact.
fprintf('Lines read in %s: %i\n', afile, length(lynes{1}));

hz = [8 4 2 1 0.5];
WorC = {'complete' 'windowed'};

for i = 1:2
    % Complete and windowed section 
    for j = 1:5

        % No arrival is marked with NaN in jd_time either because the SNR < 1
        % (which if its 1.002 will be written as 1.00e+00 in the text
        % file so be careful!) or there is no sensitivity at that
        % frequency (5 Hz SAC files have no sensitivity at 8 and 4
        % Hz).
        no_arr = sum(isnan(jd_time{i}(:,j)));
        fprintf(['Number no arrival in %s segmentation at %.1f Hz: ' ...
                 '%i.\n'], WorC{i}, hz(j), no_arr)
        
    end
end

fprintf('Total number of 20 Hz records: %i.\n', length(find(fs == 20)))
fprintf('Total number of 5 Hz records: %i.\n', length(find(fs == 5)))
