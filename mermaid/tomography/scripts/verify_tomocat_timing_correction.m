function verify_tomocat_timing_correction
% VERIFY_TOMOCAT_TIMING_CORRECTION
%
% Verfies milli-centisecond rouinding (but printed to 3 decimal places;
% dumb!) is finally fixed.
%
% Author: Joel D. Simon <jdsimon@bathymetrix.com>
% Last modified: 15-Jun-2026, 9.13.0.2553342 (R2022b) Update 9 on MACI64 (geo_mac)
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Problem: `roundmsec` attempting to round 3 decimal places to 2, but still
% print 3 total decimals (3rd always 0) via
%
% msec = str2num(str(end-3:end));
% csec = round(msec, 2);
% str(end-3:end) = [];
% str = sprintf('%s%.2f', str, csec);
%
% This was an attempt fix of the previously documentent rounding error in
% `write_tomocat1.m` (4ef83ef7b5366adc40f414ec234ce0a102296147):
%
% rounded_sttime_decimal = num2str(round(str2double(sttime(end-3:end)), 2));
%
% %% ___________________________________________________________________________ %%
% %%
% %% I compute the rounded string for complete decimal, but instead of
% %% replacing complete decimal (and adding a zero if I need to, I guess) I
% %% replace the decimal hundreds with the whole decimal. Try
% %% sttime = '2018-07-06T01:49:30.603' as an example

% sttime(end) = []; % chop of 1/1000 s decimal place
% sttime(end) = rounded_sttime_decimal(end); % replace 1/100 s decimal place with rounded value
% %%
% %% ___________________________________________________________________________ %%
%
% But my fix of a problem created two new problems:
% 1). the seconds place was now 3 chars long (e.g., '2023-03-04T06:41:221.00' in tomocat1.txt)
% 2). it doesn't take into acount rounding+1 s (e.g., ''2023-03-04 06:41:22.998' in EQ.PreferredTime)

old_mer = read_tomocat1('old_tomocat.txt');
new_mer = read_tomocat1('new_tomocat.txt');

% Verify no old SAC missing
if ~all(ismember(old_mer.filename, new_mer.filename))
    error('New doesn''t contain old filenames')

end

% These I need to chop the third seconds digit off
old_eventtime = old_mer.event_time;
old_seistime = old_mer.seismogram_time;

for i = 1:length(old_eventtime);
    old_eventtime{i}(20) = [];
    old_seistime{i}(20) = [];

end

old_eventdate = fdsnstr2date(old_eventtime);
old_seisdate = fdsnstr2date(old_seistime);

% These can be imediately converted to datetimes
new_eventtime = new_mer.event_time;
new_seistime = new_mer.seismogram_time;

new_eventdate = fdsnstr2date(new_eventtime);
new_seisdate = fdsnstr2date(new_seistime);

% Expectation: dates either all match (general case; mostly just 0 padded on
% a correct round), or dates off by exactly 1 s (bad rounding that didn't
% advance, e.g., '2018-07-06T01:49:59.995' to  '2018-07-06T01:50:00.000'.
event_idx = find(old_eventdate ~= new_eventdate);
seis_idx = find(old_seisdate ~= new_seisdate);


if all(seconds(new_eventdate(event_idx) - old_eventdate(event_idx))) ~= 1;
    error()

end

if all(seconds(new_seisdate(seis_idx) - old_seisdate(seis_idx))) ~= 1;
    error()

end

fprintf('Tests passed\n')
