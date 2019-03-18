function EQ = reviewevt(sac, redo, diro)
% EQ = REVIEWEVT(sac, redo, diro)
%
% REVIEWEVT is the smart SAC file to event matching tool.
%
% After running sac2evt.m (or cpsac2evt.m) run this to hand-review all
% potential matches and save only the true event matches.  REVIEWEVT
% allows the smart re-review and movement of .evt between identified
% and unidentified folders, and checks to see if a file being moved
% from one folder to another is being tracked by git, and if so
% properly removes and adds them such that git history is maintained
% (though it does not commit them; that you will have to do yourself).
%
% Input:
% sac       SAC filename 
%               (def: '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
% redo      logical true to delete any existing reviewed .evt and
%               rerun REVEIWEVT on the input 
%           logical false to skip redundant review (def: false)
% diro      Path to directory containing 'raw/' and 'reviewed' 
%               subdirectories (def: $MERMAID/events/)
%
% Output:   
% *N/A*     (writes reviewed .evt file)
% EQ       EQ earthquake structure after review 
%
% REVIEWEVT loads earthquake and CP arrival-time data (.evt) and their
% associated plots (.raw.pdf) output from sac2evt.m and guides the
% user through a series of interactive prompts to review possible
% earthquake and phase matches.  Writes a reviewed EQ structure to a
% .evt file in one of three /reviewed/evt/ folders.
%
% REVIEWEVT requires the following folders exist with write permission:
%    (1) [diro]/reviewed/identified/evt/(& pdf/)
%    (2) [diro]/reviewed/unidentified/evt/ 
%    (3) [diro]/reviewed/purgatory/evt/(^ pdf/)
%
% In the example below the EQ and CP structure, as well as both pdfs
% output from sac2evt.m are loaded.  Execution is paused for
% inspection of both structures and some helpful information is
% printed to the workspace.  Here there is an obvious match:
% EQ(1).TaupTimes(1) has a theoretical p wave arrival time of 95.2
% seconds, ~1 second difference from my AIC-based arrival estimation.
% Ergo, I would pick the first phase associated with the first
% earthquake in the EQ structure positive identification (there is
% another P wave associated with EQ(4) that also arrives nearby in
% time, but its a magnitude 2.2 41 degrees away, so it's definitely
% not what generated the signal here).  
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
% For the following example run the first example in sac2evt.m, 
% then make these required directories:
% mkdir ~/cpsac2evt_example/reviewed/identified/evt/
% mkdir ~/cpsac2evt_example/reviewed/unidentified/evt/
% mkdir ~/cpsac2evt_example/reviewed/purgatory/evt/
%
% Finally, 
%
% Ex: (winnow EQ structure by selecting first-arriving P wave assoc. w/ first event)
%    sac = '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac';
%    diro = '~/cpsac2evt_example'
%    EQ  = REVIEWEVT(sac, true, diro)    
%    
% See also: sac2evt.m, cpsac2evt.m
%
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 04-Dec-2018, Version 2017b

% If running this code recursively on MAC it may be hard to close all
% the windows with every new earthquake review. May need this; though
% I'm unsure of its efficacy:
%
% defaults write com.apple.Preview NSQuitAlwaysKeepsWindows -bool false
%
% Basically I have not had luck consistently killing Preview and
% having it open fresh without all the old windows.  Have to command-W
% to clear the window when closing.

%% !! Recursive !!

defval('sac', '20180629T170731.06_5B3F1904.MER.DET.WLT5.sac')
defval('redo', false)
defval('diro', fullfile(getenv('MERMAID'), 'events'))

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

switch computer
  case 'GLNXA64'
    open_pdf = 'evince %s &';
    close_pdf = 'evince';

  case 'MACI64'
    % Must use '-F' option to not reopen every previous .pdf (killall on
    % Mac with Preview reopens all previous windows).  This does
    % not always work and is annoying.
    open_pdf = 'open -F %s';
    close_pdf = 'Preview';

  otherwise
    error(['\No known viewer .pdf for your system.  Update switch/case ' ...
           'block with preferred viewer.'])

end

for i = 1:length(pdfdir)
    system(sprintf(open_pdf, fullfile(pdfdir(i).folder, pdfdir(i).name)));

end

%% Display EQ(s) info and ask if identified.

ynflag = false;
if ~isempty(EQ)
    % For domain = 'time-scale cpevet.m smooths the abe, dbe, and aicj
    % curves s.t. they their normalized values are tacked to the
    % (rough) middle of the representative time smear.  The two
    % boundaries of the time smear of the arrival index, however, are
    % plotted as vertical lines.  For the generic 'reference' time of
    % the arrival, used below for a helpful message about difference
    % between the theoretical and wavelet-AIC arrival times, again
    % take the center of the time smear to be the representative
    % arrival time.
    switch CP(1).domain
      case 'time-scale'
          for i = 1:length(CP(1).arsecs)
              if ~isnan(CP(1).arsamp{i})
                  beg_samp = CP(1).arsamp{i}(1);
                  end_samp  = CP(1).arsamp{i}(2);
                  mid_samp = round(beg_samp + 0.5*(end_samp - beg_samp));
                  JDSarsecs(i) = CP(1).outputs.xax(mid_samp);
              else
                  JDSarsecs(i) = NaN;
                  
              end
          end

      otherwise
        JDSarsecs = cell2mat(CP(1).arsecs);

    end

    % These list the first phase of the largest earthquake.
    fprintf( '\n     Filename: %s\n', sacname)     
    fprintf( '\n     *First arrival associated with largest magnitude earthquake [EQ(1)]*')
    fprintf( '\n     *Phase:             %5s',       EQ(1).TaupTimes(1).phaseName)
    fprintf( '\n     *Magnitude:         %5.1f',     EQ(1).PreferredMagnitudeValue)
    fprintf( '\n     *Distance:          %5.1f',     EQ(1).TaupTimes(1).distance)
    fprintf( '\n     *Depth:             %5.1f\n\n', EQ(1).PreferredDepth)
    fprintf( '\n     *TauP arrival time: %5.1f',     EQ(1).TaupTimes(1).arsecs)
    fprintf(['\n     *JDS time residual:' sprintf(repmat('%6.1f', ...
            [1 length(JDSarsecs)]), JDSarsecs - EQ(1).TaupTimes(1).arsecs)])


    % These list all phases of largest earthquake.
    fprintf(['\n     EQ(1) TauP phases:       ' sprintf(repmat('  %5s', [1 ...
                        length([EQ(1).TaupTimes.phaseName])]), ...
                                      EQ(1).TaupTimes.phaseName) '\n']);

    fprintf([ '     EQ(1) TauP arrival times:' sprintf(repmat('  %5.1f', [1 ...
                        length([EQ(1).TaupTimes.arsecs])]), ...
                                      EQ(1).TaupTimes.arsecs) '\n\n']);

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
        yn = strtrim(input('\n     Is this event identified? [Y/N/M/back]: ', 's'));


        if sum(strcmpi(yn, {'y' 'yes' 'n' 'no' 'm' 'maybe' 'back'})) ~= 1
            fprintf(['\n     Please input either ''Y'' (yes), ''N'' (no), ' ...
                     '''M'' (maybe) or ''back''.\n'])
            
        elseif strcmpi(yn, 'back')
            fprintf(['\n     Paused execution again for repeat inspection.\n', ...
                     '     Type ''dbcont'' to continue.\n\n'])
            keyboard
            continue
                
        else
            ynflag = true;

        end
    end
else
    yn = 'N';
    fprintf(['     EQ structure is empty and thus this event is unidentified.\n', ...
             '     Execution paused for inspection, though no further action required.\n', ...
             '     Type ''dbcont'' to continue.\n\n'])
    keyboard

end
    

%% Pick EQ(s) and phase(s), or initiate an empty reviwed EQ structure.

switch lower(yn)
  case {'y', 'yes', 'm', 'maybe'}
   
    if any(strcmp(yn, {'y' 'yes'}))
        status = 'identified';
        
    else
        status = 'purgatory';

    end

    eqflag = false;
    while ~eqflag
        eq = strtrim(input('     Matched EQ(s): ', 's'));

        if strcmpi(eq, 'restart')
            % !! Recursive !!
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
            fprintf(['\n     Please specify integer value between ' ...
                     '[1:%i], inclusive.\n\n'], length(EQ))
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
                                    'EQ(%i): '],  eq(i)), 's');
                
                if strcmpi(strtrim(ph), 'restart')
                    % !! Recursive !!
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
                    fprintf(['\n     Please specify integer value between ' ...
                             '[1:%i], inclusive.\n\n'], length(EQ(eq(i)).TaupTimes))
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

% Delete old reviewed .evt file, if it exists.  If file is tracked by
% git, use git rm.
if previously_reviewed
    oldfile = fullfile(old_review.folder, old_review.name);
    if isgitfile(oldfile)
        git_tracked = true;

        % Must cd to directory; can't use git -C with archaic git version (<1.8.5).
        startdir = pwd;  
        cd(old_review.folder)
        [~, ~] = system(sprintf('git rm -- %s', old_review.name));
        fprintf('\n\n Ran "git rm -- %s" in %s', old_review.name, ...
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
        fprintf('Deleted: %s\n', oldfile)

    end
end

% Save the new reviewed .evt file  (as a mat file).  
clear('EQ')
EQ = rev_EQ;
newfile = fullfile(rev_diro, status, 'evt', [sans_sac '.evt']);
save(newfile, 'EQ', '-mat')

% If moving a file previously tracked by git to a new location, use
% git add.
if previously_reviewed && git_tracked
    startdir = pwd;
    [new_review.folder, name, ext] = fileparts(newfile);
    new_review.name = [name ext];
    cd(new_reveiw.folder)
    [~, ~] = system(sprintf('git add -- %s', new_review.name));
    fprintf('\n\n Ran "git add -- %s" in %s', new_review.name, ...
            new_review.folder)
    
    try
        cd(startdir)

    end

else
    fprintf('\nWrote: %s\n', newfile)

end

