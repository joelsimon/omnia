function writefirstarrivals(s, redo, filename)

% Wish list: remove offending line.

defval('s', psac)
defval('redo', false)
defval('filename', fullfile(getenv('MERMAID'), 'events', 'reviewed', ...
                            'identified', 'txt', 'firstarrivals.m'))
defval('wlen', 30)
defval('lohi', [1 5])
defval('sacdir', fullfile(getenv('MERMAID'), 'processed'))
defval('evtdir', fullfile(getenv('MERMAID'), 'events'))

% Data format.
fmt = ['%44s    '  , ...
       '%8.4f    ' , ...
       '%6.2f    ' , ...
       '%4.1f    ' , ...
       '%5s    '   , ...
       '%6.2f    ' , ...
       '%6.2f    ' , ...
       '%5.2f    ' , ...
       '%10.3E    ', ...
       '%9.3E\n'];


% Flag to skip_check in following loop if the file does not yet exist.
file_exists = (exist(filename,'file') == 2);

wline = [];
wlines = [];
linecount = 0;
for i = 1:5
   sac = s{i};

    if file_exists & ~redo
       if ~isempty(mgrep(filename, strippath(sac)))
           continue

       end
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
    % Grant write access to file, if write-protected.
    if file_exists
        fileattrib(filename, '+w')

    end

    % Append new lines to the text file.
    fid = fopen(filename, 'a+');
    fprintf(fid, wlines);
    fclose(fid);

    % Write protect the file.
    fileattrib(filename, '-w')

    fprintf('Appended %i new lines to:\n%s\n', linecount, filename)
end

%_______________________________________________________________________________%

function wline = single_wline(sac, ci, wlen, lohi, sacdir, evtdir, fmt)

[tres, dat, syn, ph, delay, twosd, ~, ~, ~, maxc_y, SNR, EQ] = ...
    firstarrival(sac, true, wlen, lohi, sacdir, evtdir);


data = {strippath(sac),                ...
        EQ(1).TaupTimes(1).distance,   ...
        EQ(1).PreferredDepth,          ...
        EQ(1).PreferredMagnitudeValue, ...
        EQ(1).TaupTimes(1).phaseName,  ...
        tres,                          ...
        delay,                         ...
        twosd,                         ...
        maxc_y,                        ...
        SNR};

wline = sprintf(fmt, data{:});
