% STARTUP ---> executes at launch
%
% Joel D. Simon's startup parameters.  In order for MATLAB to execute
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
% ln -s $OMNIA/omnealiud/startup.m $HOME/Documents/MATLAB/startup.m
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
% export OMNIA=$PROGRAMS/omnia
% export IRISFETCH=$PROGRAMS/irisFetch-matlab
%
% Assumes MATLAB is subsequently launched in said shell, such that
% these environmental variables are then known to MATLAB.
%
% See also: userpath, pathdef
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 01-Aug-2024, 9.13.0.2553342 (R2022b) Update 9 on MACI64
% (in reality: Intel MATLAB in Rosetta 2 running on an Apple silicon Mac)

% Open figs in right side of right monitor
set(0, 'DefaultFigurePosition', [1100   450   560   420])

% For my code, and code my code requires.
addpath(genpath(getenv('GEOCSV')))
addpath(genpath(getenv('OMNIA')))

% Remove the paper-specific paths, with generic "fig*.m" names.
rmpath(genpath(fullfile(getenv('OMNIA'), '.git')))
rmpath(genpath(fullfile(getenv('GEOCSV'), '.git')))
rmpath(genpath(fullfile(getenv('OMNIA'), 'atm')))
rmpath(genpath(fullfile(getenv('OMNIA'), 'BSSA2020')))
rmpath(genpath(fullfile(getenv('OMNIA'), 'SRL2021')))
rmpath(genpath(fullfile(getenv('OMNIA'), 'GJI2021')))
rmpath(genpath(fullfile(getenv('OMNIA'), 'JGR2025')))

% For MatTaup.
javaaddpath(fullfile(getenv('OMNIA'), 'notmycode', 'MatTaup', 'lib', 'matTaup.jar'))

% For irisFetch-Matlab.
addpath(genpath(getenv('IRISFETCH')))
javaaddpath(fullfile(getenv('IRISFETCH'), 'IRIS-WS-2.0.18.jar'))
rmpath(genpath(fullfile(getenv('IRISFETCH'), '.git')))

% Any others paths, specific to JDS
%addpath('~/programs/offline/misc')
addpath(fullfile(getenv('MERMAID'), 'iris', 'scripts'))

% For Acoustics Toolbox
%addpath(genpath(getenv('AT')))

