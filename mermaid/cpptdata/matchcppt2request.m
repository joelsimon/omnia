function matchcppt2request(triage_sac_dir, req_file, final_sac_dir)
% MATCHCPPT2REQUEST(triage_sac_dir, req_file, final_sac_dir)
%
% Matches CPPT SAC files sent by Olivier Hyvernaud to their associated
% IRIS event IDs and sends them to their respective event ID folders.
%
% Assumes these data:
% (1) have been converted to binary (from alphanumeric)
% (2) have had their channels updated from BHZ to SHZ in the header
% (3) are tracked by git
%
% Input:
% triage_sac_dir   Path to directory containing single station's unmatched SAC files
%                      (def: $MERMAID/events/cpptstations/requests/triage/TVO/)
% req_file         Request text file associated with these triaged SAC files
% final_sac_dir    Path where [event_ID]/*SAC should be created after matching
%
% Output:
% *N/A*            Moves (via git) every traiged SAC file to the appropriate
%                     event ID directory
%
% See also: requestcppttraces.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 29-Jan-2020, Version 2017b on GLNXA64
% Documented & verified: 2017.2 pp. 93-95

% Defaults.
defval('triage_sac_dir', fullfile(getenv('MERMAID'), 'events', 'cpptstations', 'requests', 'triage', 'TVO'))
defval('final_sac_dir', fullfile(getenv('MERMAID'), 'events', 'cpptstations', 'sac'))
defval('req_file', fullfile(getenv('MERMAID'), 'events', 'cpptstations', 'requests', 'TVO_2020-01-21T17:22:48.525UTC.txt'));

% Later we use git mv, which requires I be in the same dir because my
% version does not have "-C" flag.
cd(triage_sac_dir)

% Ensure they are sorted so that later we can compare their indexing
% using monotonic integers.  I know that the requests are sorted
% because I made them.
triage_sac_dir = skipdotdir(dir(triage_sac_dir));
sac_name = sort({triage_sac_dir.name}');

% Read the request textfile.
req_fmt = '%23s    %23s    %8s\n';
req_fid = fopen(req_file, 'r');
req_scan = textscan(req_fid, req_fmt);

% Parse the requested dates.
req_time = req_scan{1};
req_date =  fdsnstr2date(req_time);
req_id = req_scan{3};

% Olivier chopped off the seconds on my requests -- round the request
% dates down to the next whole minute.
for i = 1:length(req_date)
    req_shifted_date(i) = dateshift(req_date(i), 'start', 'minute');

end
req_shifted_date = req_shifted_date(:);

% For each CPPT SAC file, match the time of the SAC file with
% corresponding event ID of the identical time of (shifted) request.
for i = 1:length(sac_name)
    sac_datestr = sac_name{i}(1:16);
    sac_date(i) = datetime(sac_datestr, 'InputFormat', 'uuuu.DDD.HHmm.ss', 'TimeZone', 'UTC');

end
sac_date = sac_date(:);
[~, sac_idx, req_idx] = intersect(sac_date, req_shifted_date);

% Verify that we have matched all possible CPPT SAC files to their
% appropriate event ID.
all_sac_idx = [1:length(sac_date)]';
if ~isequal(all_sac_idx, sac_idx)
    % Deal with these as (if?) they appear, I suppose.
    error('Not every CPPT SAC file matched')

end

% Send each SAC file to the appropriate event directory.
for i = 1:length(sac_name)
    evt_id = req_id{req_idx(i)};
    evt_dir = fullfile(final_sac_dir, evt_id);
    [~, foo] = mkdir(evt_dir);
    system(sprintf('git mv -- %s %s', sac_name{i}, evt_dir));

end
