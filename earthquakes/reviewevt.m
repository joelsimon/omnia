function EQ = reviewevt(sac, redo, diro, viewr)
% EQ = REVIEWEVT(sac, redo, diro, viewer)
%
% REVIEWEVT is the smart SAC file to event matching tool.
%
% After running cpsac2evt.m run REVIEWEVT to hand-review all potential
% matches and save only the true event matches, and allows the smart
% re-review and movement of .evt between identified and unidentified
% folders.  Further, REVIEWEVT checks to see if a file being moved
% from one folder to another is being tracked by git, and if so,
% properly removes and adds them such that git history is maintained
% (though it does not commit them, you will have to do yourself; nor
% does it rm staged files already added but not committed).
%
% Input:
% sac       SAC filename 
%               (def: '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
% redo      logical true to delete any existing reviewed .evt and
%               rerun REVIEWEVT on the input 
%           logical false to skip redundant review (def: false)
% diro      Path to directory containing 'raw/' and 'reviewed' 
%               subdirectories (def: $MERMAID/events/)
% viewr     Preferred .pdf viewer  -- 
%           1: xpdf (Linux/Unix)
%           2: evince (Linux/Unix) (def)
%           3: Preview (Mac)
%           4: [currently throws error, but add your favorite here!]
%
% Output:   
% *N/A*     (writes reviewed .evt file)
% EQ       EQ earthquake structure after review 
%
% REVIEWEVT loads earthquake and CP arrival-time data (.evt) and their
% associated plots (.raw.pdf) output by cpsac2evt.m and guides the
% user through a series of interactive prompts to review possible
% earthquake and phase matches.  Writes a reviewed EQ structure to a
% .evt file in one of three /reviewed/evt/ folders.
%
% REVIEWEVT requires the following folders exist with write permission:
%    (1) [diro]/reviewed/identified/evt/
%    (2) [diro]/reviewed/unidentified/evt/ 
%    (3) [diro]/reviewed/purgatory/evt/
%
% In the example below the EQ and CP structure, as well as both pdfs
% output from cpsac2evt.m are loaded.  Execution is paused for
% inspection of both structures and some helpful information is
% printed to the workspace.  Here there is an obvious match:
% EQ(1).TaupTimes(1) has a theoretical p wave arrival time of 95.2
% seconds, ~1 second difference from my AIC-based arrival estimation.
% Ergo, I would pick the first phase associated with the first
% earthquake in the EQ structure positive identification (there is
% another P wave associated with EQ(7) that also arrives nearby in
% time, but its a magnitude 2.2 41 degrees away, so it's definitely
% not what generated the signal here).  N.B.: event locations, times,
% magnitudes are constantly changing so the EQ structure you are
% looking at may be different than what I just quoted.
%
% Run example below and when prompted type:
%
% prompt 1: dbcont  (continue execution)
% prompt 2: y       (yes, signal 'identified,' i.e., matched with a known event)
% prompt 3: 1       (first earthquake in the EQ structure)
% prompt 4: 1       (first phase of the first earthquake)
%
% If the user types 'y' at prompt 2 a winnowed .evt file is written to
%    [diro]/reviewed/identified/evt/
%
% If the user types 'n' at prompt 2 an empty .evt file is written to
%    [diro]/reviewed/unidentified/evt/
%
% If the user types 'm' (undecided) a winnowed .evt file is written to
%    [diro]/reviewed/purgatory/evt/   
%
% After prompt 1 the user may type 'back' to return to a paused state
% of execution to reexamine the EQ/AIC structures.
%
% After prompt 2 the user may type 'restart' to relaunch a fresh
% instance of REVIEWEVT, useful if input error was made.
%
% For the following example run the first Ex1 in cpsac2evt.m, 
% then make these required directories:
%
%    mkdir ~/cpsac2evt_example/reviewed/identified/evt/
%    mkdir ~/cpsac2evt_example/reviewed/unidentified/evt/
%
% Ex: (winnow EQ structure by selecting first-arriving P wave assoc. w/ first event)
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example';
%    EQ  = REVIEWEVT(sac, true, diro)    
%    
% See also: cpsac2evt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 17-Jun-2019, Version 2017b

% If using viewr = 3 (Preview) on Mac:
%
% It may be hard to close all the windows with every new earthquake
% review if running this code recursively. May need this; though I'm
% unsure of its efficacy:
%
% defaults write com.apple.Preview NSQuitAlwaysKeepsWindows -bool false
%
% Basically I have not had luck consistently killing Preview and
% having it open fresh without all the old windows.  Instead I use
% command-W to clear the window when closing.

%% Recursive.

% Defaults.
defval('sac', '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
defval('redo', false)
defval('diro', fullfile(getenv('MERMAID'), 'events'))
defval('viewr', 2)

%% Check if SAC already reviewed.

% !! JDS: Don't try to slot getevt.m here -- it's more complicated  !!
% !! than it's worth.  This works, leave it.                        !!

sacname = strippath(sac);
sans_sac =  strrep(sacname, '.sac', '');

raw_diro = fullfile(diro, 'raw');
rev_diro = fullfile(diro, 'reviewed');

old_review = dir(fullfile(rev_diro, sprintf('**/*%s.evt', sans_sac)));
previously_reviewed = false;
if ~isempty(old_review)
    previously_reviewed = true;

end

if ~redo && previously_reviewed
    EQ = getevt(sac, diro);
    fprintf(['\n%s already processed by reviewevt:\n%s\n\nSet ' ...
             '''redo'' = true to run reviewevt again.\n\n'], ...
            sacname, fullfile(old_review.folder, old_review.name))
    return
    
end

raw_evt = fullfile(raw_diro, 'evt', [sans_sac '.raw.evt']); 
temp = load(raw_evt, '-mat');
EQ = temp.EQ;
CP = temp.CP;
clear('temp')

raw_pdf = fullfile(raw_diro, 'pdf', [sans_sac '*.raw.pdf']); 
pdfdir = dir(raw_pdf);
if isempty(pdfdir)
    error('No .pdfs matching %s found.', raw_pdf)

end

%% Open raw PDFs to conduct event review.

switch viewr
  case 1
    open_pdf = 'xpdf %s &';
    close_pdf = 'xpdf';

  case 2
    open_pdf = 'evince %s &';
    close_pdf = 'evince';
    
  case 3
    % Must use '-F' option to not reopen every previous .pdf (killall on
    % Mac with Preview reopens all previous windows).  This does not
    % always work and is annoying.
    open_pdf = 'open -F %s';
    close_pdf = 'Preview';

  otherwise
    error('Input one of 1, 2, or 3 for input: ''viewr''')

end

for i = 1:length(pdfdir)
    system(sprintf(open_pdf, fullfile(pdfdir(i).folder, pdfdir(i).name)));

end

%% Pick matched events.

ynflag = false;
if ~isempty(EQ)
    % If domain = 'time-scale' and no smoothing was used (input 'fml'),
    % take the rough center of the time smear as the reference time
    % for the travel time residual printed to the screen.  
    %
    % In either case, print residuals w.r.t. to CP(1); the changepoint
    % estimates for the complete, and not the windowed, seismogram.
    if strcmp(CP(1).domain, 'time-scale') && isempty(CP(1).inputs.fml)
        for i = 1:length(CP(1).arsecs)
            beg_samp = CP(1).arsamp{i}(1);
            end_samp  = CP(1).arsamp{i}(2);
            mid_samp = round(mean([beg_samp end_samp]));
            JDSarsecs(i) = CP(1).outputs.xax(mid_samp);
            
        end
    else
        JDSarsecs = cell2mat(CP(1).arsecs);

    end

    % These list the first phase of the largest earthquake.
    fprintf( '\n     Filename: %s\n', sacname)
    fprintf( '\n     *First arrival associated with largest magnitude earthquake [EQ(1)]*')
    fprintf( '\n     *Phase:             %7s',       EQ(1).TaupTimes(1).phaseName)
    fprintf( '\n     *Magnitude:         %7.1f %s',  EQ(1).PreferredMagnitudeValue, EQ(1).PreferredMagnitudeType)
    fprintf( '\n     *Distance (deg):    %7.1f',     EQ(1).TaupTimes(1).distance)
    fprintf( '\n     *Depth (km):        %7.1f',     EQ(1).PreferredDepth)
    fprintf( '\n     *Arrival time (s):  %7.1f',     EQ(1).TaupTimes(1).truearsecs)
    fprintf(['\n     *JDS residual (s):  ' sprintf(repmat('%7.1f', ...
            [1 length(JDSarsecs)]), JDSarsecs - EQ(1).TaupTimes(1).truearsecs)])


    % These list all phases of largest earthquake.
    fprintf(['\n\n\n     All EQ(1) phases:      ' sprintf(repmat('  %5s', [1 ...
                        length([EQ(1).TaupTimes.phaseName])]), ...
                                      EQ(1).TaupTimes.phaseName) '\n']);

    fprintf([ '     All EQ(1) arrivals (s):' sprintf(repmat('  %5.1f', [1 ...
                        length([EQ(1).TaupTimes.truearsecs])]), ...
                                      EQ(1).TaupTimes.truearsecs) '\n\n']);

    % These list the magnitudes and distances of ALL earthquakes.
    fprintf(['\n     All magnitudes:' sprintf(repmat('  %5.1f', [1 ...
                        length([EQ.PreferredMagnitudeValue])]), ...
                                      EQ.PreferredMagnitudeValue) '\n']);

    for i = 1:length(EQ)
        dists(i)  = EQ(i).TaupTimes(1).distance;

    end

    fprintf([ '     All distances: ' sprintf(repmat('  %5.1f', [1 length(dists)]), dists) '\n\n']);
    fprintf(['\n     !! Paused execution -- type ''dbcont'' to continue !!\n\n'])
    keyboard

    while ~ynflag
        yn = strtrim(input('\n     Is this event identified? [Y/N/M/back/skip]: ', 's'));


        if sum(strcmpi(yn, {'y' 'yes' 'n' 'no' 'm' 'maybe' 'back' 'skip'})) ~= 1
            fprintf(['\n     Bad input: specify one of  ''Y'' (yes), ' ...
                     '''N'' (no), ''M'' (maybe), ''back'', or ''skip''.\n'])
            
        elseif strcmpi(yn, 'back')
            fprintf(['\n     Paused execution again for repeat inspection.\n', ...
                     '     Type ''dbcont'' to continue.\n\n'])
            keyboard
            continue
                
        elseif strcmpi(yn, 'skip')
            % Close .pdfs, return NaN.
            system(sprintf('killall %s', close_pdf));
            EQ = NaN;
            return

        else
            ynflag = true;

        end
    end
else
    yn = 'N';
    fprintf( '\n     Filename: %s\n\n', sacname)
    fprintf(['     EQ structure is empty and thus this event is unidentified.\n', ...
             '     Execution paused for waveform inspection, though no further action required.\n', ...
             '     An empty .evt file will automatically be sent to the ''unidentified'' directory.\n'])
    fprintf(['\n     !! Paused execution -- type ''dbcont'' to continue !!\n\n'])
    keyboard

end
    
%% Pick phases for every matched event.

switch lower(yn)
  case {'y', 'yes', 'm', 'maybe'}
   
    if any(strcmp(yn, {'y' 'yes'}))
        status = 'identified';
        
    else
        status = 'purgatory';

    end

    eqflag = false;
    while ~eqflag
        eq = strtrim(input('     Matched EQ(s) [or restart]: ', 's'));

        if strcmpi(eq, 'restart')

            %% Recursive.

            system(sprintf('killall %s', close_pdf));
            clc
            reviewevt(sac, redo, diro) 
            return

        end

        if strcmpi(eq, 'back')
            fprintf(['\n     Paused execution again for repeat inspection.\n', ...
                     '     Type ''dbcont'' to continue.\n\n'])
            keyboard
            continue
            
        end

        eq = str2num(eq);
        if ~all(ismember(eq, [1:length(EQ)])) || isempty(eq)
            fprintf('\n     Bad input: specify integer value between [1:%i], inclusive.\n\n', length(EQ))
            continue

        end

        for i = 1:length(eq)
            % Copy matched earthquake but delete associated phases for now.  
            % They will be added back after the next round of user prompts.
            rev_EQ(i) = EQ(eq(i));
            rev_EQ(i).TaupTimes = [];
            
            phflag = false;
            while ~phflag

                ph = input(sprintf(['     Matched TaupTimes(s) for ' ...
                                    'EQ(%i) [or restart]: '],  eq(i)), 's');
                
                if strcmpi(strtrim(ph), 'restart')

                    %% Recursive.
 
                    system(sprintf('killall %s', close_pdf));
                    clc
                    reviewevt(sac, redo, diro)
                    return

                end
                
                if strcmpi(strtrim(ph), 'back')
                    fprintf(['\n     Paused execution again for repeat inspection.\n', ...
                             '     Type ''dbcont'' to continue.\n\n'])
                    keyboard
                    continue
                    
                end
                
                if strcmp(strtrim(ph), ':')
                    rev_EQ(i).TaupTimes = EQ(eq(i)).TaupTimes;
                    phflag = true;
                    continue

                end

                ph = str2num(ph);
                if ~all(ismember(ph, [1:length(EQ(eq(i)).TaupTimes)])) || isempty(ph)
                    fprintf(['\n     Bad input: specify integer value between [1:%i], inclusive,\n' ...
                             '                or : [colon] to include all phases.\n\n'], ...
                            length(EQ(eq(i)).TaupTimes))
                    continue
                    
                end

                rev_EQ(i).TaupTimes = EQ(eq(i)).TaupTimes(ph);
                phflag = true;

            end
        end
        eqflag = true;

    end
  case {'n', 'no'}
    status = 'unidentified';
    rev_EQ = [];

end
system(sprintf('killall %s', close_pdf));

%% Delete (or 'git rm') the old review, if it exists.

% N.B.: the code below doesn't handle the obscure case of a file that
% has already been added but not yet committed, i.e., it won't run
%
% git rm --cached -- old_review.name
%
% in the case of a staged file.  I don't see this every happening
% outside of testing so I'm not coding for it.  Further, it would
% really confuse an end-user other than myself (JDS) unfamiliar with
% that I'm doing here.

if previously_reviewed
    oldfile = fullfile(old_review.folder, old_review.name);
    if isgitfile(oldfile)
        git_tracked = true;

        % Must cd to directory; can't use git -C with archaic git version (<1.8.5).
        startdir = pwd;  
        cd(old_review.folder)
        [~, ~] = system(sprintf('git rm -- %s', old_review.name));
        fprintf('\n\nRan "git rm -- %s" in %s', old_review.name, ...
                old_review.folder)        

        try
            % If you've just cleared a directory you can't cd into it; git
            % 'removes' empty directories.  So if you started in a
            % directory with one file, deleted it, then try to cd back
            % to the directory (which you're already in), this fails.
            % No big deal; your current path is somewhat of a
            % purgatory at this point anyway.
            cd(startdir)

        end

    else
        git_tracked = false;
        delete(oldfile)
        fprintf('\nDeleted: %s\n', oldfile)

    end
end


%% Save (and possibly, 'git add') the new review.

clear('EQ')
EQ = rev_EQ;
newfile = fullfile(rev_diro, status, 'evt', [sans_sac '.evt']);
save(newfile, 'EQ', '-mat')

if previously_reviewed && git_tracked
    startdir = pwd;
    [new_review.folder, name, ext] = fileparts(newfile);
    new_review.name = [name ext];
    cd(new_review.folder)
    [~, ~] = system(sprintf('git add -- %s', new_review.name));
    fprintf('\n\nRan "git add -- %s" in %s', new_review.name, ...
            new_review.folder)
    
    try
        % Same note for try statement, above.
        cd(startdir)

    end
else
    fprintf('\nWrote:   %s\n\n', newfile)

end
