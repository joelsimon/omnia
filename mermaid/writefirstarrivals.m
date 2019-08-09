function writefirstarrivals(s, redo, filename)

defval('s', psac)
defval('redo', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrivals.txt'))
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

% Data format.
fmt = ['%44s    ' , ...
       '%5s    '  , ...
       '%6.2f    ', ...
       '%6.2f    ', ...
       '%5.2f    ', ...
       '%9.1f    ' , ...
       '%11i\n'];


% logical flag: does the file exist?
file_exists = (exist(filename,'file') == 2);

% Sort out if deleting, appending to, or creating output file.
if file_exists 
    % Grant write access to file.
    fileattrib(filename, '+w')

    if redo
        % Clear existing contents.
        fid = fopen(filename, 'w');
        fprintf('Deleted:\n%s\n\n', filename);
        verb = 'Wrote';

    else
        % Append to existing contents.
        fid = fopen(filename, 'a');
        verb = 'Appended';

    end
else
    % Generate new file.
    fid = fopen(filename, 'w+');
    fprintf('Created:\n%s\n\n', filename);
    verb = 'Wrote';

end

wline = [];
wlines = [];
linecount = 0;
for i = 1:length(s)
   sac = s{i};
   
   % Skip SAC files that are already written.
   if ~isempty(mgrep(filename, strippath(sac)))
       continue
       
   end

   % Concatenate the write lines.
   wline = single_wline(sac, true, wlen, lohi, sacdir, evtdir, fmt);
   wlines = [wlines wline];

   % Keep track of number of lines (over)written.
   linecount = [linecount + 1];

end

if isempty(wline)
    % Nothing to do if there are no new lines to write.
    fprintf('No new lines written to:\n%s\n', filename)

else
    % Append new lines to the text file.
    fprintf(fid, wlines);
    fclose(fid);

    % Write protect the file.
    fileattrib(filename, '-w')

    % Exit with informative printout.
    fprintf('%s %i lines to:\n%s\n', verb, linecount, filename)
end

%_______________________________________________________________________________%

function wline = single_wline(sac, ci, wlen, lohi, sacdir, evtdir, fmt)

[tres, dat, syn, ph, delay, twosd, ~, ~, ~, maxc_y, SNR] = ...
    firstarrival(sac, true, wlen, lohi, sacdir, evtdir);

data = {strippath(sac), ...
        ph,             ...
        tres,           ...
        delay,          ...
        twosd,          ...
        SNR,            ...
        round(maxc_y)};

wline = sprintf(fmt, data{:});
