% STARTUP ---> executes at launch
%
% Joel D Simon's startup parameters.  In order for MATLAB to execute
% this file at launch you must place it MATLAB's native search path.
% This may be found with the command "userpath".  For me:
%
% '/home/jdsimon/Documents/MATLAB'
%
% Being that I want to push this online and keep it under git vc I
% have placed the original STARTUP file in $OMNIA/omnealiud, and
% symlinked a version to the above path (assuming $OMNIA is set, see
% below):
%
% ln -s $OMNIA/omnealiud/startup.m /home/jdsimon/Documents/MATLAB/startup.m
%
% Alternatively, one may simply move this file to the latter path.
%
%_____________________________________________________________%
%
% STARTUP requires the environmental variables OMNIA and IRISFETCH to
% be defined in your preferred shell's config file:
% 
% with "export" for bash-like (bash, sh, zsh), -or-
% with "setenv" in csh-like (csh, tsch).
%
% For me:
% export OMNIA='/home/jdsimon/github/omnia'
% export IRISFETCH='/home/jdsimon/github/irisFetch-matlab'
%
% Assumes MATLAB is subsequently launched in said shell, such that
% these environmental variables are then known to MATLAB.
% 
% See also: userpath.m
% 
% Author: Joel D. Simon
% Contact: jdsimon@princeton.edu
% Last modified: 01-Mar-2019, Version 2017b

% For my code, and code my code requires.
addpath(genpath(getenv('OMNIA')))
javaaddpath(fullfile(getenv('OMNIA'), 'notmycode', 'MatTaup', 'lib', ...
                     'matTaup.jar'));

% For irisFetch-Matlab.
addpath(genpath(getenv('IRISFETCH')))
javaaddpath(fullfile(getenv('IRISFETCH'), 'IRIS-WS-2.0.18.jar'))

% For MatTaup.
% % Update javaclasspath for MatTaup
% javaaddpath(fullfile(getenv('MFILES'), 'notmycode/MatTaup/lib/matTaup.jar'))

% % Update javaclasspath for irisFetch.m
% %addpath(genpath(fullfile(getenv('OMNIA'),'notmycode', 'irisFetch-matlab')))
% javaaddpath(fullfile(getenv('GITHUB'),'irisFetch-matlab', ...
%                      'IRIS-WS-2.0.18.jar'))


%_________________________________________%








% mfiles = getenv('MFILES');
% addpath(mfiles);
% addpath('~/conferences')

% %'IRISFETCH',...

% dirs = {'atm',...
%         'atm/Sunday',...
%         'wenbo',...
%         'conferences/iris18',...
%         'changepoints/tests',...
%         'changepoints',...
%         'earthquakes',...
%         'exfiles', ...
%         'geoazur/' ...
%         'mermaid',...
%         'mermaid/scripts/',...
%         'normly',...
%         'notmycode',...
%         'notmycode/fjs',...
%         'notmycode/MatTaup',...
%         'omnealiud',...
%         'papers/simon2019',...
%         'papers/simon2019/biased_variance',...
%         'papers/simon2019/Static',...
%         'plotbits',...
%         'r',...
%         'sonomermaid',...
%         'wavelets'};

        
% for i = 1:length(dirs);
%     addpath(fullfile(mfiles, dirs{i}))
% end


% % Update javaclasspath for MatTaup
% javaaddpath(fullfile(getenv('MFILES'), 'notmycode/MatTaup/lib/matTaup.jar'))

% % Update javaclasspath for irisFetch.m
% addpath(genpath(fullfile(getenv('GITHUB'),'irisFetch-matlab')))
% javaaddpath(fullfile(getenv('GITHUB'),'irisFetch-matlab','IRIS-WS-2.0.18.jar'))

% cd('~/Desktop/')
% beep('off')
% clear all


%____________________________%

