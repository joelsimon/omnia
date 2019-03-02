function [linenum, linestr, idx] = mgrep(file, regex, num_matches, ignorecase)
% [linenum,linestr,idx] = MGREP(file,regex,num_matches,ignorecase)
%
% MATLAB file grep(ish) using REGULAR EXPRESSIONS -- 'regex' is not
% interpreted as a string literal, so beware of '+' etc.
%
% Searches a file for matching strings.  Returns the line number,
% complete line, and beginning indices of any matches in each line.
% Accepts regular expressions.  Slow, but less error prone than
% system('grep ...') calls.  
%
% Inputs:
% file             Name of file 
% regex            Regular expression to find in text file
% num_matches      Number of matches to find before quitting
%                      (def: read entire file)*
% ignorecase       logical true to ignore case (def: false)
%                    
% Outputs:
% linenum          Line number (assuming \n delimiter) in text file
%                      of each match (def: [])
% linestr          Char cell of complete line in text file that contains
%                     each match (def: {})
% idx              Cell of beginning indices of matches
%                      corresponding to each line (def: {})
%
% * Number of lines in the file with matches, not the number of
% matches per line (a regexp option). Compare to -m in grep.
%
% Ex: (first 6 occurrences of 'SNR=' in arbitrarily formatted file)
%    [linenum,linestr,idx] = MGREP('test80211.txt','SNR=',6,false)
%
% See also: readtext.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 24-Jan-2018, Version 2017b

% Defaults.
defval('num_matches',-1)
defval('ignorecase',false)

% Sanity.
if ~isint(num_matches)
    error('Input argument ''num_matches'' must be an integer.')
end
if ~islogical(ignorecase)
    error('Input argument ''ignorecase'' must be logical.')
end

% Open, read, close.
fid = fopen(file, 'r');
if fid == -1
    error('Cannot read %s. Check path and permissions.', file)
end

% Switch regexp.m flag concerning cases.
if ignorecase == true
    option = 'ignorecase';
else
    option = 'matchcase';
end

% Default outputs, assuming string not found in text file.
linenum = [];
linestr = {};
idx = {};

%% Main.
% Run through every line of the file. Record matches if any. Quit
% search if the number of matches requested is met.
line_number = 0;
match_num = 0;
while 1
    % Nab the next line in the file.
    tline = fgetl(fid);

    % Have we reached the end of the file?
    if ~ischar(tline)
        break 
    end

    % If not, add to the line counter.
    line_number = line_number + 1;

    % Does the line match?
    matches = regexp(tline, regex, option);
    if ~isempty(matches)
        match_num = match_num + 1;
        linenum = [linenum; line_number];
        linestr{match_num} = tline;
        idx{match_num} = matches;

        % Have we reached the limit of requested matches?
        if match_num == num_matches
            break
        end

    end
end
linestr = linestr';
idx = idx';
fclose(fid);

