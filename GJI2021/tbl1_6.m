function tbl1_6
% TBL1_6
%
% Writes Tables 1-6: seismicity statistics compiled, and parsed per magnitude.
%
% Before running this, run: simon2021gji_writeglobalcatalog_thru2019.m
% DONE -- *was re-run on 16-Mar-2021 with automaid v3+ updated data set*
%
% Developed as: simon2020_writestats.m
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 23-Jun-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Define paths.
merdir = getenv('MERMAID');
procdir = fullfile(merdir, 'processed');
evtdir = fullfile(merdir, 'events');

% Ensure in GJI21 git branch -- complimentary paper w/ same data set.
startdir = pwd;
cd(procdir)
system('git checkout GJI21');
cd(evtdir)
system('git checkout GJI21');
cd(startdir)

enddate = datetime('31-Dec-2019 23:59:59.999', 'TimeZone', 'UTC');
returntype = 'DET';
savepath = fullfile(getenv('GJI21_CODE'), 'data');
idfilepath = fullfile(evtdir, 'reviewed', 'identified', 'txt');
floatnum = {'08' '09' '10' '11', '12', '13', '16', '17', '18', '19', ...
           '20', '21', '22', '23', '24', '25'};
magval = [4:8];

% 30-yr average seismicity rates (Jan 1985 through Dec 2014) per
% magnitude unit from 4-8 (see ./data/1985-2015/M?.txt)
historical_num_ev = [365378 48511 3650 396 28]; % DOUBLY verified 17-Jan-2020/29-Mar-2020
historical_num_ev_per_yr = historical_num_ev / 30;
fprintf('\nM4--M8 average annual seismicity rate: %i %i %i %i %i\n', round(historical_num_ev_per_yr))

% Load the MERMAID locations/dates.
%% MERMAID structure -- currently uses (old) four-character station names "P008"
%% Eventually we will want to update to all five-character station names
mer = readmerloc;

% Text file formats.
%% TEXTFILES -- write with five-character station names "P0008"
fmt11 = ' P00%2s: & %6i & %3i & %5.1f%s & %3i & %3i & %3i & %3i \\\\\n';
fmt12 = '%5s: & %6i & %3i & %5.1f%s & %3i & %3i & %3i & %3i \\\\\n';

%  Write stats per magnitude per float:
%
%  i == mag. unit, j == float number

%% For each magnitude value.
count = 0;
for i = 1:length(magval)
    mercatfile = fullfile(idfilepath, sprintf('M%i_%s.txt', magval(i), returntype));
    [eqtime_master, ~, ~, ~, ~, ~, mertot_master, ~, mernumstr_master] = ...
        readmermaidglobalcatalog(mercatfile, length(floatnum));

    % Convert eqtimes to datetimes for easily computation of durations.
    eqdate_master = fdsnstr2date(eqtime_master);

    % Allow write access, if necessary, and open text file.
    filename = sprintf(fullfile(savepath, 'M%i_stats.txt'), magval(i));
    writeaccess('unlock', filename, false)
    fid = fopen(filename, 'w');

    %% For each float.
    for j = 1:length(floatnum)
        deploydate{j} = mer.(sprintf('P0%2s', floatnum{j})).date(1);

        % Winnow the events to just those within the requested time range
        idx = find(isbetween(eqdate_master, deploydate{j}, enddate));
        eqtime{j} = eqtime_master(idx);
        mertot{j} = mertot_master(idx);
        mernumstr{j} = mernumstr_master(idx);

        % Number of events, number of IDs, ratio and percentage of IDs.
        num_ev(j) = length(eqtime{j});
        num_id(j) = length(cellstrfind(mernumstr{j}, floatnum{j}));
        id_ratio(j) = num_id(j) / num_ev(j);

        id_perc(j) = id_ratio(j) * 100;

        % Time from deployment to requested end date.
        time_duration(j) = enddate - deploydate{j};
        num_day(j) = days(time_duration(j));
        num_wk(j) = num_day(j) / 7;
        num_yr(j) = years(time_duration(j));

        % Average number of events per year considering only the date range.
        num_ev_per_wk(j) = num_ev(j) / num_wk(j);
        num_ev_per_yr(j) = num_ev(j) / num_yr(j);

        % Rate of identification by time period.
        num_id_per_wk(j) = num_id(j) / num_wk(j);
        num_id_per_yr(j) = num_id(j) / num_yr(j);
        num_id_per_5yr(j) = num_id_per_yr(j) * 5;

        % We then want to compare these returns using the percentage over the
        % time duration applied to the 30yr average of number of events.
        exp_num_id_per_yr(j) = id_ratio(j) * historical_num_ev_per_yr(i);
        exp_num_id_per_5yr(j) = exp_num_id_per_yr(j) * 5;

        % Concatenate data.
        data = {floatnum{j}, ...
                num_ev(j), ...
                num_id(j), ...
                id_perc(j), ...
                '\%', ...
                round(num_id_per_yr(j)), ...
                round(num_id_per_5yr(j)), ...
                round(exp_num_id_per_yr(j)), ...
                round(exp_num_id_per_5yr(j))};

        fprintf(fid, fmt11, data{:});

        count = count + 1;
        nid(count) = num_id(j);
        nday(count) = num_day(j);
        nyr(count) = num_yr(j);
        nidyr(count) = num_id_per_yr(j);

    end
    %% End per float.

    % Summed stats per magnitude unit over all MERMAIDs.
    sum_num_id_per_mag(i) = sum(num_id);
    mean_num_id_per_mag(i) = mean(num_id);

    sum_num_wk_per_mag(i) = sum(num_wk);
    mean_num_wk_per_mag(i) = mean(num_wk);

    sum_num_yr_per_mag(i) = sum(num_yr);
    mean_num_yr_per_mag(i) = mean(num_yr);

    sum_num_ev_per_mag(i) = sum(num_ev);
    mean_num_ev_per_mag(i) = mean(num_ev);

    % This percentage is the mean by summing all percentages across all
    % floats and dividing by 16.  It is different than taking the sum
    % of IDs across all 16 and dividing by the number of events across
    % all 16.
    % mean_id_perc_per_mag(i) = mean(id_perc);
    % e.g.:
    % sum_num_id_per_mag(i)/sum_num_ev_per_mag(i)*100
    % which is equal to
    % mean_num_id_per_mag(i)/mean_num_ev_per_mag(i)*100

    sum_num_id_per_yr_per_mag(i) = sum(num_id_per_yr);
    mean_num_id_per_yr_per_mag(i) = mean(num_id_per_yr);

    sum_num_id_per_5yr_per_mag(i) = sum(num_id_per_5yr);
    mean_num_id_per_5yr_per_mag(i) = mean(num_id_per_5yr);

    sum_exp_num_id_per_yr_per_mag(i) = sum(exp_num_id_per_yr);
    mean_exp_num_id_per_yr_per_mag(i) = mean(exp_num_id_per_yr);

    sum_exp_num_id_per_5yr_per_mag(i) = sum(exp_num_id_per_5yr);
    mean_exp_num_id_per_5yr_per_mag(i) = mean(exp_num_id_per_5yr);

    % Write summary statistics considering all floats for a given magnitude.
    sum_data = {'Total', ...
                sum_num_ev_per_mag(i), ...
                sum_num_id_per_mag(i), ...
                (sum_num_id_per_mag(i) / sum_num_ev_per_mag(i)) * 100, ...
                '\%', ...
                round(sum_num_id_per_yr_per_mag(i)), ...
                round(sum_num_id_per_5yr_per_mag(i)),  ...
                round(sum_exp_num_id_per_yr_per_mag(i)), ...
                round(sum_exp_num_id_per_5yr_per_mag(i))};
    fprintf(fid, '\\hline\n');
    fprintf(fid, fmt12, sum_data{:});

    mean_data = {'Mean', ...
                 round(mean_num_ev_per_mag(i)), ...
                 round(mean_num_id_per_mag(i)), ...
                 (mean_num_id_per_mag(i) / mean_num_ev_per_mag(i)) * 100, ...
                 '\%', ...
                 round(mean_num_id_per_yr_per_mag(i)), ...
                 round(mean_num_id_per_5yr_per_mag(i)),  ...
                 round(mean_exp_num_id_per_yr_per_mag(i)), ...
                 round(mean_exp_num_id_per_5yr_per_mag(i))};
    fprintf(fid, '\\hline\\hline\n');
    fprintf(fid, fmt12, mean_data{:});

    fclose(fid);
    writeaccess('lock', filename)
    fprintf('%s\n', filename);

end
%% End per mag.


%_______________________________________________________________________%

%% Write stats across all magnitudes.

% Load all possible reports (not just those ID'd).
incl_prelim = false;
all_det_sac = readevt2txt([], [], enddate, 'DET', incl_prelim);
id_det_sac = readidentified([], [], enddate, 'SAC', 'DET', incl_prelim); % reftime = 'SAC' in keeping with readevt2txt.m restriction barring 'EVT'

fmt21 = ' P00%2s: & %11s & %6.1f & %4i & %3i & %6.1f%s \\\\\n';
filename = sprintf(fullfile(savepath, 'ALL_stats.txt'));
writeaccess('unlock', filename, false)
fid = fopen(filename, 'w');
for j = 1:length(floatnum)
    num_report(j) = length(cellstrfind(all_det_sac, sprintf('.%s_', floatnum{j})));
    num_id_report(j) = length(cellstrfind(id_det_sac, sprintf('.%s_', floatnum{j})));
    id_report_ratio(j) = num_id_report(j) / num_report(j);
    id_report_perc(j) = id_report_ratio(j) * 100;

    data = {floatnum{j}, ...
            datestr(deploydate{j}, 'dd-mmm-yyyy'), ...
            num_wk(j), ...
            num_report(j), ...
            num_id_report(j), ...
            id_report_perc(j), ...
            '\%'};

    fprintf(fid, fmt21, data{:});

end

fmt22 = 'Total: &             & %6.1f & %4i & %3i & %6.1f%s  \\\\\n';
fmt23 = 'Mean:  &             & %6.1f & %4i & %3i & %6.1f%s  \\\\\n';
sum_data = {sum(num_wk), ...
            sum(num_report), ...
            sum(num_id_report), ...
            (sum(num_id_report) / sum(num_report)) * 100, ...
            '\%'};

fprintf(fid, '\\hline\n');
fprintf(fid, fmt22, sum_data{:});

mean_data = {mean(num_wk), ...
             round(mean(num_report)), ...
             round(mean(num_id_report)), ...
             (mean(num_id_report) / mean(num_report)) * 100, ... % isequal to (sum(num_id_report) / sum(num_report)) * 100
             '\%'};
fprintf(fid, '\\hline\\hline\n');
fprintf(fid, fmt23, mean_data{:});

fclose(fid);
writeaccess('lock', filename)
fprintf('%s\n', filename);

%_______________________________________________________________________%

%% All statistics, with the per yr breakdown.

fmt31 = ' P00%2s: & %11s & %6.1f & %4i & %3i & %6.1f%s & %5i & %4i \\\\\n';
filename = sprintf(fullfile(savepath, 'ALL_stats_yr.txt'));
writeaccess('unlock', filename, false)
fid = fopen(filename, 'w');
for j = 1:length(floatnum)
    num_report(j) = length(cellstrfind(all_det_sac, sprintf('.%s_', floatnum{j})));
    num_report_per_yr(j) = num_report(j) / num_yr(j);
    num_id_report(j) = length(cellstrfind(id_det_sac, sprintf('.%s_', floatnum{j})));
    num_id_report_per_yr(j) = num_id_report(j) / num_yr(j);
    id_report_ratio(j) = num_id_report(j) / num_report(j);
    id_report_perc(j) = id_report_ratio(j) * 100;

    data = {floatnum{j}, ...
            datestr(deploydate{j}, 'dd-mmm-yyyy'), ...
            num_wk(j), ...
            num_report(j), ...
            num_id_report(j), ...
            id_report_perc(j), ...
            '\%', ...
            round(num_report_per_yr(j)), ...
            round(num_id_report_per_yr(j))};

    fprintf(fid, fmt31, data{:});

end

fmt32 = 'Total: &             & %6.1f & %4i & %3i & %6.1f%s & %5i & %4i \\\\\n';
fmt33 = 'Mean:  & %11s & %6.1f & %4i & %3i & %6.1f%s & %5i & %4i \\\\\n';
sum_data = {sum(num_wk), ...
            sum(num_report), ...
            sum(num_id_report), ...
            (sum(num_id_report) / sum(num_report)) * 100, ...
            '\%', ...
            round(sum(num_report_per_yr)), ...                  % *1
            round(sum(num_id_report_per_yr))};                  % *1
fprintf(fid, '\\hline\n');
fprintf(fid, fmt32, sum_data{:});

mean_deploydate = mean([deploydate{:}]);
mean_data = {datestr(mean_deploydate, 'dd-mmm-yyyy'), ...
             mean(num_wk), ...
             round(mean(num_report)), ...
             round(mean(num_id_report)), ...
             (mean(num_id_report) / mean(num_report)) * 100, ...
             '\%', ...
             round(mean(num_report_per_yr)), ...          % *1
             round(mean(num_id_report_per_yr))};          % *1
fprintf(fid, '\\hline\\hline\n');
fprintf(fid, fmt33, mean_data{:});
fclose(fid);
writeaccess('lock', filename)
fprintf('%s\n', filename);

%% I've removed this inside rounding -- I think I'd rather the totals/means be
%% accurate than necessarily consistent with the rows; i.e., a column need not sum
%% exactly to the "total" row.  This note is no longer true, see 30-Mar-2020 change.
% *1: We must round inside the sum/mean operator because it is the sum
%     of the column, whose values are already rounded --
%
% sum(round(num_report_per_yr)) ~= round(sum(num_report_per_yr))
%

%% 30-Mar-2020 change:
% The last line in sum_data used to read:
%
%        sum(round(num_report_per_yr)),
%
% So that the total in the column equaled if you totaled all the rounding
% numbers above it, and the last line of mean_data,
%
%    round(mean(round(num_id_report_per_yr))),
%
% for the same reason.

fprintf('Total years of deployment: %.2f\n', sum(nyr(1:16)))
fprintf('Mean years of deployment:  %.2f\n', mean(nyr(1:16)))

% End main
%_______________________________________________________________________%
%_______________________________________________________________________%

% Some validations.
tot_id1 = sum(sum_num_id_per_mag);
tot_id2 = sum(nidyr .* nyr);
if ~isequal(tot_id1, tot_id2) || ~isint(tot_id1) || ~isint(tot_id2)
    error('Total IDs by two methods do not match and/or are not integer')

end
fprintf('\nTotal ID: %i (which should equal all returntype %s IDs up to %s)\n', tot_id1, returntype, datestr(enddate))
fprintf('Sum([# IDs/float/year]*[years/float]): %i (should equal number above)\n', tot_id2)

% These should also both equal tot_id*, and each other.
if ~(sum(mean_num_id_per_mag) * length(floatnum) == sum(sum_num_id_per_mag))
    error('Total IDs do not match')

end

% Notes to self.
    %% Weighted average:
    %
    % \hat(x) = sum(w_i*x_i) / sum(w_i)
    %
    % where w are the weights; i.e., the years each float was deployed.

    % This number therefore is an "average" of the number of IDs per float
    % considering the ENTIRE deployment; it is not per year.  So it is
    % very close to the ordinary arithmetic mean for the entire deployment: tot_id1/16

    ids_weighed_by_yrs = sum(nid .* nyr);
    total_yrs = sum(nyr(1:16));
    weighted_ave_id = ids_weighed_by_yrs / total_yrs;

    % All IDs in a single year for a single float, multiplied by 5 (projected lifespan).
    sum(mean_num_id_per_5yr_per_mag);

    % Percentage of IDs over entire deployment multiplied by number of earthquakes expected in 5 years.
    sum(mean_exp_num_id_per_5yr_per_mag);

    % PS: this makes the float (M) x magnitude (N) matrix
    nid_mn = reshape(nid, 16, 5);
    nyr_mn = reshape(nyr, 16, 5); % every column equal because every the sampling for every mag. unit equal
% End notes to self.
