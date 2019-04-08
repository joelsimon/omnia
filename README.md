## Installation:  

1. Before running any code in omnia, the following environmental variables (all
paths) must be added to your shell's configuration file; for me --
    - export GITHUB=$HOME/github
    - export OMNIA=$GITHUB/omnia
    - export IFILES=$OMNIA/notmycode/fjs/IFILES
    - export IRISFETCH=$GITHUB/irisFetch-matlab
    
2. My startup.m must be added to your MATLAB path, or added to an existing
startup.m file.  If you have not yet created one, type 'userpath' in the MATALB
command window to find where it should be placed.  I softlinked mine to my
userpath to maintain git version control; for me --
    -  ln -s $OMNIA/omnealiud/startup.m ~/Documents/MATLAB/startup.m  